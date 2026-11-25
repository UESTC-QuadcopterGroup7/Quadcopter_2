using System;
using System.Diagnostics;
using System.IO;
using System.IO.Ports;
using System.Security.Cryptography;
using System.Text;

public static class QuadcopterBluetoothUploader
{
    private const int AppBase = 0x08004000;
    private const int ImageLimit = 0x3BFD4;
    private const int ChunkSize = 256;
    private const byte Info = 1, Begin = 2, Data = 3, Finish = 4;
    private static readonly byte[] Wake = Encoding.ASCII.GetBytes("!QBT-UP!\n");
    private static readonly byte[] Empty = new byte[0];

    private static uint Crc32(byte[] bytes, int start, int count)
    {
        uint crc = uint.MaxValue;
        for (int i = start; i < start + count; i++)
        {
            crc ^= bytes[i];
            for (int bit = 0; bit < 8; bit++)
                crc = (crc >> 1) ^ ((crc & 1u) == 0 ? 0u : 0xedb88320u);
        }
        return ~crc;
    }

    private static void WritePacket(SerialPort serial, byte cmd, byte[] payload)
    {
        byte[] packet = new byte[9 + payload.Length];
        packet[0] = (byte)'Q';
        packet[1] = (byte)'B';
        packet[2] = cmd;
        packet[3] = (byte)payload.Length;
        packet[4] = (byte)(payload.Length >> 8);
        Buffer.BlockCopy(payload, 0, packet, 5, payload.Length);
        byte[] crc = BitConverter.GetBytes(Crc32(packet, 2, 3 + payload.Length));
        Buffer.BlockCopy(crc, 0, packet, 5 + payload.Length, crc.Length);
        serial.Write(packet, 0, packet.Length);
    }

    private static byte ReadByte(SerialPort serial, Stopwatch timer, int timeoutMs)
    {
        while (timer.ElapsedMilliseconds < timeoutMs)
        {
            try { return (byte)serial.ReadByte(); }
            catch (TimeoutException) {}
        }
        throw new TimeoutException("No matching response from the bootloader.");
    }

    private static byte[] ReadReply(SerialPort serial, byte cmd, int timeoutMs, int offset)
    {
        var timer = Stopwatch.StartNew();
        bool sawQ = false;
        while (true)
        {
            byte b = ReadByte(serial, timer, timeoutMs);
            if (!sawQ || b != 'B')
            {
                sawQ = b == 'Q';
                continue;
            }
            sawQ = false;
            byte type = ReadByte(serial, timer, timeoutMs);
            int size = ReadByte(serial, timer, timeoutMs);
            size |= ReadByte(serial, timer, timeoutMs) << 8;
            if (size < 1 || size > 6) continue;

            byte[] body = new byte[3 + size + 4];
            body[0] = type;
            body[1] = (byte)size;
            for (int i = 3; i < body.Length; i++)
                body[i] = ReadByte(serial, timer, timeoutMs);
            if (type != (cmd | 0x80) ||
                Crc32(body, 0, 3 + size) != BitConverter.ToUInt32(body, 3 + size))
                continue;
            if (body[3] != 0)
                throw new IOException(DescribeFailure(cmd, body[3]));
            if (cmd == Data && (size != 5 || BitConverter.ToInt32(body, 4) != offset))
                continue;
            byte[] payload = new byte[size];
            Buffer.BlockCopy(body, 3, payload, 0, size);
            return payload;
        }
    }

    private static string DescribeFailure(byte cmd, byte status)
    {
        string reason;
        switch (status)
        {
            case 1: reason = "invalid command, image size, or data offset"; break;
            case 2: reason = "flash erase, write, or verification error"; break;
            case 3: reason = "wrong image key, CRC, or firmware layout"; break;
            default: reason = "unrecognized status " + status; break;
        }
        return String.Format("Bootloader rejected command {0}: {1}.", cmd, reason);
    }

    private static byte[] Connect(SerialPort serial, int seconds)
    {
        var timer = Stopwatch.StartNew();
        while (timer.Elapsed.TotalSeconds < seconds)
        {
            serial.Write(Wake, 0, Wake.Length);
            WritePacket(serial, Info, Empty);
            try
            {
                byte[] info = ReadReply(serial, Info, 650, -1);
                if (info.Length != 6 || info[1] != 1)
                    throw new IOException("Unsupported bootloader version.");
                return info;
            }
            catch (TimeoutException) {}
        }
        throw new TimeoutException("No bootloader response. Check COM port, PA10 wiring and SWD installation. For a motor-enabled build, reset the board while this tool waits.");
    }

    private static byte[] PrepareImage(byte[] image, byte[] key)
    {
        if (image.Length < 8 || image.Length > ImageLimit)
            throw new ArgumentException("Firmware size is outside the BluetoothApp slot.");
        uint stack = BitConverter.ToUInt32(image, 0);
        uint reset = BitConverter.ToUInt32(image, 4);
        if (stack <= 0x20000000u || stack > 0x20018000u || (stack & 7) != 0 ||
            (reset & 1) == 0 || reset < AppBase + 8 || reset >= AppBase + image.Length)
            throw new ArgumentException("Expected a BluetoothApp BIN linked at 0x08004000.");
        byte[] begin = new byte[40];
        Buffer.BlockCopy(BitConverter.GetBytes(image.Length), 0, begin, 0, 4);
        Buffer.BlockCopy(BitConverter.GetBytes(Crc32(image, 0, image.Length)), 0, begin, 4, 4);
        using (var hmac = new HMACSHA256(key))
        {
            Buffer.BlockCopy(hmac.ComputeHash(image), 0, begin, 8, 32);
        }
        return begin;
    }

    public static void Run(string port, byte[] image, byte[] key, int connectSeconds)
    {
        byte[] begin = image == null ? null : PrepareImage(image, key);
        using (var serial = new SerialPort(port, 115200, Parity.None, 8, StopBits.One))
        {
            serial.Handshake = Handshake.None;
            serial.ReadTimeout = 100;
            serial.WriteTimeout = 2000;
            serial.Open();
            Console.WriteLine("Waiting for the bootloader on {0} (115200 8N1)...", port);
            byte[] info = Connect(serial, connectSeconds);
            uint limit = BitConverter.ToUInt32(info, 2);
            Console.WriteLine("Bootloader v{0}, application capacity {1} bytes.", info[1], limit);
            if (image == null) return;
            if (image.Length > limit) throw new ArgumentException("Firmware exceeds device capacity.");

            Console.WriteLine("Erasing the staging slot...");
            WritePacket(serial, Begin, begin);
            ReadReply(serial, Begin, 30000, -1);
            int lastPercent = -10;
            for (int offset = 0; offset < image.Length; offset += ChunkSize)
            {
                int count = Math.Min(ChunkSize, image.Length - offset);
                byte[] payload = new byte[4 + count];
                Buffer.BlockCopy(BitConverter.GetBytes(offset), 0, payload, 0, 4);
                Buffer.BlockCopy(image, offset, payload, 4, count);
                for (int attempt = 0; ; attempt++)
                {
                    WritePacket(serial, Data, payload);
                    try { ReadReply(serial, Data, 1800, offset); break; }
                    catch (TimeoutException) { if (attempt == 2) throw; }
                }
                int percent = 100 * (offset + count) / image.Length;
                if (percent >= lastPercent + 10 || percent == 100)
                {
                    Console.WriteLine("Uploaded {0}%", percent);
                    lastPercent = percent;
                }
            }
            Console.WriteLine("Verifying and installing...");
            WritePacket(serial, Finish, Empty);
            ReadReply(serial, Finish, 60000, -1);
            Console.WriteLine("Application installed and verified. The board is restarting.");
        }
    }
}
