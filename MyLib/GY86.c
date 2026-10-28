#include "main.h"
#include "MyI2C.h"
#include "GY86.h"

uint8_t already_init = 0;

volatile uint8_t g_HmcAddressAck = 1;
volatile uint8_t g_HmcIdentity[3] = {0xFF, 0xFF, 0xFF};

volatile MPU6050_Offset_t g_MpuOffset = {0};
volatile uint16_t g_MpuCalibrationCount = 0;
volatile uint8_t g_MpuCalibrationActive = 0;

static MPU6050_Offset_t mpu_calibration_sum = {0};
static uint32_t mpu_calibration_last_tick = 0;
static uint8_t mpu_read_failed = 0;

void MPU6050_CalibrationStart(void)
{
    MPU6050_Offset_t zero = {0};

    g_MpuCalibrationActive = 0;
    g_MpuOffset = zero;
    mpu_calibration_sum = zero;
    g_MpuCalibrationCount = 0;
    mpu_calibration_last_tick = HAL_GetTick() - 10u;
    g_MpuCalibrationActive = 1;
}

uint8_t MPU6050_CalibrationStatus(void)
{
    return g_MpuCalibrationActive;
}

static int16_t MPU6050_SubtractOffset(int16_t raw, int32_t offset)
{
    int32_t value = (int32_t)raw - offset;

    if (value > 32767) {
        value = 32767;
    } else if (value < -32768) {
        value = -32768;
    }
    return (int16_t)value;
}

static void MPU6050_CalibrateSample(int16_t *ax, int16_t *ay, int16_t *az,
                                   int16_t *gx, int16_t *gy, int16_t *gz)
{
    uint32_t now = HAL_GetTick();

    if (mpu_read_failed != 0) {
        return;
    }

    /* 当前输出速率为 100 Hz；校准样本至少间隔 10 ms，并使用未补偿原始值。 */
    if (g_MpuCalibrationActive != 0 &&
        (uint32_t)(now - mpu_calibration_last_tick) >= 10u) {
        mpu_calibration_last_tick = now;
        mpu_calibration_sum.ax += *ax;
        mpu_calibration_sum.ay += *ay;
        mpu_calibration_sum.az += *az;
        mpu_calibration_sum.gx += *gx;
        mpu_calibration_sum.gy += *gy;
        mpu_calibration_sum.gz += *gz;
        g_MpuCalibrationCount++;

        if (g_MpuCalibrationCount == MPU6050_CALIBRATION_SAMPLES) {
            g_MpuOffset.ax = mpu_calibration_sum.ax / (int32_t)MPU6050_CALIBRATION_SAMPLES;
            g_MpuOffset.ay = mpu_calibration_sum.ay / (int32_t)MPU6050_CALIBRATION_SAMPLES;
            /* 水平静止且传感器 +Z 朝上，保留重力，不把 Z 轴校准为零。 */
            g_MpuOffset.az = mpu_calibration_sum.az / (int32_t)MPU6050_CALIBRATION_SAMPLES
                             - MPU6050_ACCEL_1G_RAW;
            g_MpuOffset.gx = mpu_calibration_sum.gx / (int32_t)MPU6050_CALIBRATION_SAMPLES;
            g_MpuOffset.gy = mpu_calibration_sum.gy / (int32_t)MPU6050_CALIBRATION_SAMPLES;
            g_MpuOffset.gz = mpu_calibration_sum.gz / (int32_t)MPU6050_CALIBRATION_SAMPLES;
            g_MpuCalibrationActive = 0;
        }
    }

    if (g_MpuCalibrationActive == 0 &&
        g_MpuCalibrationCount == MPU6050_CALIBRATION_SAMPLES) {
        *ax = MPU6050_SubtractOffset(*ax, g_MpuOffset.ax);
        *ay = MPU6050_SubtractOffset(*ay, g_MpuOffset.ay);
        *az = MPU6050_SubtractOffset(*az, g_MpuOffset.az);
        *gx = MPU6050_SubtractOffset(*gx, g_MpuOffset.gx);
        *gy = MPU6050_SubtractOffset(*gy, g_MpuOffset.gy);
        *gz = MPU6050_SubtractOffset(*gz, g_MpuOffset.gz);
    }
}

/*
 * MPU6050配置函数
 */
void MPU6050_WriteReg(uint8_t RegAddr, uint8_t data) {
	MyI2C_Start();
	MyI2C_SendByte(MPU6050_ADDRESS);
	MyI2C_ReceiveAck();
	MyI2C_SendByte(RegAddr);
	MyI2C_ReceiveAck();
	MyI2C_SendByte(data);
	MyI2C_ReceiveAck();
	MyI2C_Stop();
}

void MPU6050_Init(void) {
	if(!already_init){
		MyI2C_Init();
		already_init = 1;
	}
	MPU6050_WriteReg(MPU6050_PWR_MGMT_1,0x01);
	MPU6050_WriteReg(MPU6050_PWR_MGMT_2,0x00);
        /* 采样率：1kHz / (1 + SMPLRT_DIV)。0x04 → 200Hz，
         * 原来 0x09 只有 100Hz，光是等下一次采样就带来 ~5ms 平均延迟。 */
	MPU6050_WriteReg(MPU6050_SMPLRT_DIV,0x04);
        /* 数字低通：0x01 = 184Hz 带宽（群延迟 ~1.9ms），
         * 原来 0x02 = 94Hz（~2.9ms）。想回到更平滑的曲线就改回 0x02。 */
	MPU6050_WriteReg(MPU6050_CONFIG,0x01);
	MPU6050_WriteReg(MPU6050_GYRO_CONFIG,0x18);
        MPU6050_WriteReg(MPU6050_ACCEL_CONFIG,MPU6050_ACCEL_CONFIG_VALUE);
        /* 关闭 MPU 的 I2C 主机并开启旁路，让 STM32 直接访问辅助总线地磁计。 */
        MPU6050_WriteReg(MPU6050_USER_CTRL,0x00);
        MPU6050_WriteReg(MPU6050_INT_PIN_CFG,0x02);
}

uint8_t MPU6050_ReadReg(uint8_t RegAddr) {
	uint8_t RecByte;
	MyI2C_Start();
	MyI2C_SendByte(MPU6050_ADDRESS);
        if (MyI2C_ReceiveAck() != 0) {
                mpu_read_failed = 1;
                MyI2C_Stop();
                return 0xFF;
        }
	MyI2C_SendByte(RegAddr);
        if (MyI2C_ReceiveAck() != 0) {
                mpu_read_failed = 1;
                MyI2C_Stop();
                return 0xFF;
        }
	
	MyI2C_Start();
	MyI2C_SendByte(MPU6050_ADDRESS | 0x01);
        if (MyI2C_ReceiveAck() != 0) {
                mpu_read_failed = 1;
                MyI2C_Stop();
                return 0xFF;
        }
	RecByte = MyI2C_ReceiveByte();
	MyI2C_SendAck(1);
	MyI2C_Stop();
	return RecByte;
}

/*
 * 从 RegAddr 开始连续读 len 个字节（MPU6050 寄存器地址自动递增）。
 *
 * 原来是每个寄存器单独起一次 I2C 事务，加速度+陀螺共 12 次；
 * 在软件 I2C 上每次事务都要几百微秒，累计十几毫秒，直接把采样率压到 40Hz。
 * 改用突发读后整帧只要一次事务。
 */
static void MPU6050_ReadBurst(uint8_t RegAddr, uint8_t *buf, uint8_t len)
{
	uint8_t i;

	MyI2C_Start();
	MyI2C_SendByte(MPU6050_ADDRESS);
	if (MyI2C_ReceiveAck() != 0) {
		mpu_read_failed = 1;
		MyI2C_Stop();
		return;
	}
	MyI2C_SendByte(RegAddr);
	if (MyI2C_ReceiveAck() != 0) {
		mpu_read_failed = 1;
		MyI2C_Stop();
		return;
	}

	MyI2C_Start();
	MyI2C_SendByte(MPU6050_ADDRESS | 0x01);
	if (MyI2C_ReceiveAck() != 0) {
		mpu_read_failed = 1;
		MyI2C_Stop();
		return;
	}

	for (i = 0; i < len; i++) {
		buf[i] = MyI2C_ReceiveByte();
		/* 最后一个字节回 NACK，其余回 ACK */
		MyI2C_SendAck((uint8_t)((i + 1u == len) ? 1u : 0u));
	}
	MyI2C_Stop();
}

void MPU6050_GetData(int16_t* AccX, int16_t* AccY, int16_t* AccZ, int16_t* GyroX, int16_t* GyroY, int16_t* GyroZ) {
	uint8_t raw[14];

    mpu_read_failed = 0;

	/* 0x3B ~ 0x48：加速度 6 字节 + 温度 2 字节 + 陀螺 6 字节 */
	MPU6050_ReadBurst(MPU6050_ACCEL_XOUT_H, raw, 14);

	*AccX  = (int16_t)(((uint16_t)raw[0]  << 8) | raw[1]);
	*AccY  = (int16_t)(((uint16_t)raw[2]  << 8) | raw[3]);
	*AccZ  = (int16_t)(((uint16_t)raw[4]  << 8) | raw[5]);
	/* raw[6]、raw[7] 是温度，当前不使用 */
	*GyroX = (int16_t)(((uint16_t)raw[8]  << 8) | raw[9]);
	*GyroY = (int16_t)(((uint16_t)raw[10] << 8) | raw[11]);
	*GyroZ = (int16_t)(((uint16_t)raw[12] << 8) | raw[13]);

    MPU6050_CalibrateSample(AccX, AccY, AccZ, GyroX, GyroY, GyroZ);
}

uint8_t MPU6050_GetId(void) {
	return MPU6050_ReadReg(MPU6050_WHO_AM_I);
}

/*
 * HMC5883L配置函数
 */
void HMC5883L_WriteReg(uint8_t RegAddr, uint8_t data) {
	MyI2C_Start();
	MyI2C_SendByte(HMC5883L_ADDRESS);
	MyI2C_ReceiveAck();
	MyI2C_SendByte(RegAddr);
	MyI2C_ReceiveAck();
	MyI2C_SendByte(data);
	MyI2C_ReceiveAck();
	MyI2C_Stop();
}
void HMC5883L_Init(void) {
	if(!already_init){
		MyI2C_Init();
		already_init = 1;
	}
        /* ACK 为 0 表示器件应答；正常 HMC5883L 的 ID 为 48 34 33（H43）。 */
        MyI2C_Start();
        MyI2C_SendByte(HMC5883L_ADDRESS);
        g_HmcAddressAck = MyI2C_ReceiveAck();
        MyI2C_Stop();
        if (g_HmcAddressAck != 0) {
                return;
        }
        g_HmcIdentity[0] = HMC5883L_ReadReg(HMC5883L_ID_A);
        g_HmcIdentity[1] = HMC5883L_ReadReg(HMC5883L_ID_B);
        g_HmcIdentity[2] = HMC5883L_ReadReg(HMC5883L_ID_C);
	HMC5883L_WriteReg(HMC5883L_CONFIG_A,0x18);
	HMC5883L_WriteReg(HMC5883L_CONFIG_B,0x20);
	HMC5883L_WriteReg(HMC5883L_MODE,0x00);
}

uint8_t HMC5883L_ReadReg(uint8_t RegAddr) {
	uint8_t RecByte;
	MyI2C_Start();
	MyI2C_SendByte(HMC5883L_ADDRESS);
	MyI2C_ReceiveAck();
	MyI2C_SendByte(RegAddr);
	MyI2C_ReceiveAck();

	MyI2C_Start();
	MyI2C_SendByte(HMC5883L_ADDRESS | 0x01);
	MyI2C_ReceiveAck();
	RecByte = MyI2C_ReceiveByte();
	MyI2C_SendAck(1);
	MyI2C_Stop();
	return RecByte;
}

static void HMC5883L_ReadBurst(uint8_t RegAddr, uint8_t *buf, uint8_t len)
{
	uint8_t i;

	MyI2C_Start();
	MyI2C_SendByte(HMC5883L_ADDRESS);
	if (MyI2C_ReceiveAck() != 0) {
		MyI2C_Stop();
		return;
	}
	MyI2C_SendByte(RegAddr);
	if (MyI2C_ReceiveAck() != 0) {
		MyI2C_Stop();
		return;
	}

	MyI2C_Start();
	MyI2C_SendByte(HMC5883L_ADDRESS | 0x01);
	if (MyI2C_ReceiveAck() != 0) {
		MyI2C_Stop();
		return;
	}

	for (i = 0; i < len; i++) {
		buf[i] = MyI2C_ReceiveByte();
		MyI2C_SendAck((uint8_t)((i + 1u == len) ? 1u : 0u));
	}
	MyI2C_Stop();
}

void HMC5883L_GetData(int16_t* X, int16_t* Y, int16_t* Z) {
	uint8_t raw[6];

	HMC5883L_ReadBurst(HMC5883L_XOUT_MSB, raw, 6);

	/* HMC5883L 的输出顺序是 X、Z、Y —— 芯片固有顺序，不是笔误 */
	*X = (int16_t)(((uint16_t)raw[0] << 8) | raw[1]);
	*Z = (int16_t)(((uint16_t)raw[2] << 8) | raw[3]);
	*Y = (int16_t)(((uint16_t)raw[4] << 8) | raw[5]);
}

/*
 * MS561101BA (MS5611) 气压计相关函数
 */
#include <math.h>

// 校准数据与加载标志（非静态，供 ReadPeripherals 等模块访问）
MS561101BA_CalibData_t ms5611_calib;
uint8_t ms5611_calib_loaded = 0;

// 发送复位命令
void MS561101BA_Reset(void) {
    if(!already_init){
        MyI2C_Init();
        already_init = 1;
    }
    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr);
    MyI2C_ReceiveAck();
    MyI2C_SendByte(MS561101BA_RESET);
    MyI2C_ReceiveAck();
    MyI2C_Stop();
    // 复位后等待芯片内部重置完成（典型2.8ms）
    HAL_Delay(3);
}

// 读取 PROM 中的一个系数（index: 0..7，其中1..6为C1..C6）
uint16_t MS561101BA_ReadPROM(uint8_t index) {
    uint8_t msb, lsb;
    uint8_t prom_addr = MS561101BA_PROM_BASE_ADDR + (index << 1);

    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr);
    MyI2C_ReceiveAck();
    MyI2C_SendByte(prom_addr);
    MyI2C_ReceiveAck();
    
    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr | 0x01);
    MyI2C_ReceiveAck();
    msb = MyI2C_ReceiveByte();
    MyI2C_SendAck(0);
    lsb = MyI2C_ReceiveByte();
    MyI2C_SendAck(1);
    MyI2C_Stop();
    
    return ((uint16_t)msb << 8) | lsb;
}

// 读取全部PROM校准数据 C1..C6 到结构体
void MS561101BA_ReadPROM_All(MS561101BA_CalibData_t* calib) {
    calib->C1 = MS561101BA_ReadPROM(1);
    calib->C2 = MS561101BA_ReadPROM(2);
    calib->C3 = MS561101BA_ReadPROM(3);
    calib->C4 = MS561101BA_ReadPROM(4);
    calib->C5 = MS561101BA_ReadPROM(5);
    calib->C6 = MS561101BA_ReadPROM(6);
}

// 根据 OSR 获取转换所需延时（毫秒）
static uint8_t MS561101BA_GetDelayMs(uint8_t osr) {
    switch(osr) {
        case MS561101BA_OSR_256:  return 1;  // 0.6ms
        case MS561101BA_OSR_512:  return 2;  // 1.2ms
        case MS561101BA_OSR_1024: return 3;  // 2.3ms
        case MS561101BA_OSR_2048: return 5;  // 4.6ms
        case MS561101BA_OSR_4096: return 10; // 9.04ms
        default: return 3;
    }
}

// 启动 D1（压力）转换
void MS561101BA_StartConversionD1(uint8_t osr) {
    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr);
    MyI2C_ReceiveAck();
    MyI2C_SendByte(MS561101BA_D1 + osr);
    MyI2C_ReceiveAck();
    MyI2C_Stop();
}

// 启动 D2（温度）转换
void MS561101BA_StartConversionD2(uint8_t osr) {
    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr);
    MyI2C_ReceiveAck();
    MyI2C_SendByte(MS561101BA_D2 + osr);
    MyI2C_ReceiveAck();
    MyI2C_Stop();
}

// 读取 ADC 结果（3 字节，24bit）
uint32_t MS561101BA_ReadADC(void) {
    uint8_t b1, b2, b3;
    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr);
    MyI2C_ReceiveAck();
    MyI2C_SendByte(0x00); // ADC Read 命令
    MyI2C_ReceiveAck();

    MyI2C_Start();
    MyI2C_SendByte(MS561101BA_Addr | 0x01);
    MyI2C_ReceiveAck();
    b1 = MyI2C_ReceiveByte();
    MyI2C_SendAck(0);
    b2 = MyI2C_ReceiveByte();
    MyI2C_SendAck(0);
    b3 = MyI2C_ReceiveByte();
    MyI2C_SendAck(1);
    MyI2C_Stop();
    
    return ((uint32_t)b1 << 16) | ((uint32_t)b2 << 8) | (uint32_t)b3;
}

// 读取原始压力 D1
uint32_t MS561101BA_ReadPressureRaw(uint8_t osr) {
    MS561101BA_StartConversionD1(osr);
    HAL_Delay(MS561101BA_GetDelayMs(osr));
    return MS561101BA_ReadADC();
}

// 读取原始温度 D2
uint32_t MS561101BA_ReadTemperatureRaw(uint8_t osr) {
    MS561101BA_StartConversionD2(osr);
    HAL_Delay(MS561101BA_GetDelayMs(osr));
    return MS561101BA_ReadADC();
}

// 初始化：复位并读取 PROM 校准系数
void MS561101BA_Init(void) {
    MS561101BA_Reset();
    MS561101BA_ReadPROM_All(&ms5611_calib);
    ms5611_calib_loaded = 1;
}

// 纯计算函数：根据原始 ADC 值 D1、D2 和已加载的校准系数，计算补偿后的温度、气压与海拔。
// 可从 RTOS 任务中调用，不需要阻塞等待 I2C（D1/D2 由外部通过非阻塞方式获取）。
uint8_t MS561101BA_Calculate(uint32_t D1, uint32_t D2, MS561101BA_Data_t* data) {
    if (!ms5611_calib_loaded) return 0;

    int32_t dT = (int32_t)D2 - ((int32_t)ms5611_calib.C5 << 8);
    int32_t TEMP = 2000 + (int32_t)(((int64_t)dT * (int64_t)ms5611_calib.C6) / 8388608); // 2^23

    int64_t OFF  = ((int64_t)ms5611_calib.C2 << 16) + (((int64_t)ms5611_calib.C4 * (int64_t)dT) >> 7);
    int64_t SENS = ((int64_t)ms5611_calib.C1 << 15) + (((int64_t)ms5611_calib.C3 * (int64_t)dT) >> 8);

    if (TEMP < 2000) {
        int32_t T2 = (int32_t)(((int64_t)dT * (int64_t)dT) >> 31);
        int64_t temp_minus = (int64_t)(TEMP - 2000);
        int64_t OFF2 = (5 * temp_minus * temp_minus) >> 1;
        int64_t SENS2 = (5 * temp_minus * temp_minus) >> 2;
        if (TEMP < -1500) {
            int64_t temp_plus = (int64_t)(TEMP + 1500);
            OFF2 += 7 * temp_plus * temp_plus;
            SENS2 += (11 * temp_plus * temp_plus) >> 1;
        }
        TEMP -= T2;
        OFF -= OFF2;
        SENS -= SENS2;
    }

    int32_t P = (int32_t)(((((int64_t)D1 * SENS) >> 21) - OFF) >> 15);

    data->temperature = TEMP / 100.0f;
    data->pressure = (float)P; // P is already in Pa (0.01 mbar)
    data->altitude = 44330.0f * (1.0f - powf(data->pressure / 101325.0f, 0.1903f));

    return 1;
}

// 阻塞式完整读取（内部调用 HAL_Delay，保留用于非 RTOS 上下文）
uint8_t MS561101BA_GetData(MS561101BA_Data_t* data, uint8_t osr) {
    uint32_t D2 = MS561101BA_ReadTemperatureRaw(osr);
    uint32_t D1 = MS561101BA_ReadPressureRaw(osr);
    return MS561101BA_Calculate(D1, D2, data);
}
