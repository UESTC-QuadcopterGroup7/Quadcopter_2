/*
 * 定义匿名上位机的协议帧
 */

#include "main.h"
#include "ANO.h"
#include "UART_Set.h"

/* ---- 协议常量 ---------------------------------------------------------- */

#define ANO_HEAD_BYTE     0xAAu
#define ANO_TARGET_ADDR   0xFFu   /* 0xFF = 广播；个别版本要用 0xAF，改这里即可 */

/* 功能码 */
#define ANO_FUN_FC_MOTION 0x01u
#define ANO_FUN_FC_ENV    0x02u
#define ANO_FUN_FC_ATT    0x03u
#define ANO_FUN_USER_1    0xF1u

#define ANO_MAX_CHANNELS  10u
#define ANO_BUF_SIZE      (6u + 4u * ANO_MAX_CHANNELS)

/* ---- 组帧发送 ---------------------------------------------------------- */

static void ANO_SendPacket(uint8_t fun, const uint8_t *payload, uint8_t len)
{
    uint8_t  buf[ANO_BUF_SIZE];
    uint8_t  sum = 0;
    uint8_t  add = 0;
    uint16_t i;

    if (len > (uint8_t)(4u * ANO_MAX_CHANNELS)) {
        return;
    }

    buf[0] = ANO_HEAD_BYTE;
    buf[1] = ANO_TARGET_ADDR;
    buf[2] = fun;
    buf[3] = len;

    for (i = 0; i < (uint16_t)len; i++) {
        buf[4u + i] = payload[i];
    }

    for (i = 0; i < (uint16_t)(4u + len); i++) {
        sum = (uint8_t)(sum + buf[i]);
        add = (uint8_t)(add + sum);
    }

    buf[4u + len] = sum;
    buf[5u + len] = add;

    HAL_UART_Transmit(&huart1, buf, (uint16_t)(6u + len), 100u);
}

/* ---- 定点量化 ---------------------------------------------------------- */

static int16_t ANO_Quantize(float value, float lsb)
{
    float scaled = value * lsb;

    if (scaled >= 32767.0f) {
        return 32767;
    }
    if (scaled <= -32768.0f) {
        return -32768;
    }
    return (int16_t)(scaled >= 0.0f ? (scaled + 0.5f) : (scaled - 0.5f));
}

static void ANO_WriteI16LE(uint8_t *out, int16_t value)
{
    uint16_t bits = (uint16_t)value;

    out[0] = (uint8_t)bits;
    out[1] = (uint8_t)(bits >> 8);
}

static void ANO_WriteU32LE(uint8_t *out, uint32_t bits)
{
    out[0] = (uint8_t)bits;
    out[1] = (uint8_t)(bits >> 8);
    out[2] = (uint8_t)(bits >> 16);
    out[3] = (uint8_t)(bits >> 24);
}

/* ---- 通用帧 ------------------------------------------------------------ */

void ANO_SendInt16s(uint8_t fun, const int16_t *values, uint8_t count)
{
    uint8_t  payload[4u * ANO_MAX_CHANNELS];
    uint16_t i;

    if (values == 0 || count == 0u || count > ANO_MAX_CHANNELS) {
        return;
    }

    for (i = 0; i < (uint16_t)count; i++) {
        ANO_WriteI16LE(&payload[2u * i], values[i]);
    }

    ANO_SendPacket(fun, payload, (uint8_t)(2u * count));
}

void ANO_SendFloats(uint8_t fun, const float *values, uint8_t count)
{
    uint8_t payload[4u * ANO_MAX_CHANNELS];
    union {
        float    f;
        uint32_t u;
    } cvt;
    uint16_t i;

    if (values == 0 || count == 0u || count > ANO_MAX_CHANNELS) {
        return;
    }

    for (i = 0; i < (uint16_t)count; i++) {
        cvt.f = values[i];
        ANO_WriteU32LE(&payload[4u * i], cvt.u);
    }

    ANO_SendPacket(fun, payload, (uint8_t)(4u * count));
}

/* ---- 飞控固定帧 -------------------------------------------------------- */

void ANO_SendFC_AccGyr(const float acc_ms2[3], const float gyr_dps[3], uint8_t shock)
{
    uint8_t payload[13];
    uint8_t axis;

    for (axis = 0u; axis < 3u; ++axis) {
        ANO_WriteI16LE(&payload[2u * axis], ANO_Quantize(acc_ms2[axis], ANO_LSB_ACC));
        ANO_WriteI16LE(&payload[6u + 2u * axis], ANO_Quantize(gyr_dps[axis], ANO_LSB_GYR));
    }
    payload[12] = shock;

    ANO_SendPacket(ANO_FUN_FC_MOTION, payload, sizeof(payload));
}

void ANO_SendFC_MagBaro(const int16_t mag[3], int32_t alt_cm, float temp_c,
                        uint8_t sta_bar, uint8_t sta_mag)
{
    uint8_t payload[14];
    uint8_t axis;

    for (axis = 0u; axis < 3u; ++axis) {
        ANO_WriteI16LE(&payload[2u * axis], mag[axis]);
    }
    ANO_WriteU32LE(&payload[6], (uint32_t)alt_cm);
    ANO_WriteI16LE(&payload[10], ANO_Quantize(temp_c, 10.0f));
    payload[12] = sta_bar;
    payload[13] = sta_mag;

    ANO_SendPacket(ANO_FUN_FC_ENV, payload, sizeof(payload));
}

void ANO_SendFC_Attitude(float roll_deg, float pitch_deg, float yaw_deg)
{
    uint8_t payload[7];

    ANO_WriteI16LE(&payload[0], ANO_Quantize(roll_deg, ANO_LSB_ATT));
    ANO_WriteI16LE(&payload[2], ANO_Quantize(pitch_deg, ANO_LSB_ATT));
    ANO_WriteI16LE(&payload[4], ANO_Quantize(yaw_deg, ANO_LSB_ATT));
    payload[6] = 0u; /* FUSION_STA：当前只上报已初始化的姿态角。 */

    ANO_SendPacket(ANO_FUN_FC_ATT, payload, sizeof(payload));
}
