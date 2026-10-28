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

/* ---- 通用帧 ------------------------------------------------------------ */

void ANO_SendInt16s(uint8_t fun, const int16_t *values, uint8_t count)
{
    uint8_t  payload[4u * ANO_MAX_CHANNELS];
    uint16_t i;

    if (values == 0 || count == 0u || count > ANO_MAX_CHANNELS) {
        return;
    }

    for (i = 0; i < (uint16_t)count; i++) {
        payload[2u * i]      = (uint8_t)(values[i] & 0xFF);
        payload[2u * i + 1u] = (uint8_t)(((uint16_t)values[i] >> 8) & 0xFF);
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
        payload[4u * i]      = (uint8_t)(cvt.u & 0xFF);
        payload[4u * i + 1u] = (uint8_t)((cvt.u >> 8) & 0xFF);
        payload[4u * i + 2u] = (uint8_t)((cvt.u >> 16) & 0xFF);
        payload[4u * i + 3u] = (uint8_t)((cvt.u >> 24) & 0xFF);
    }

    ANO_SendPacket(fun, payload, (uint8_t)(4u * count));
}

/* ---- 飞控固定帧 -------------------------------------------------------- */

void ANO_SendFC_AccGyr(const float acc_ms2[3], const float gyr_dps[3], uint8_t shock)
{
    int16_t v[7];

    v[0] = ANO_Quantize(acc_ms2[0], ANO_LSB_ACC);
    v[1] = ANO_Quantize(acc_ms2[1], ANO_LSB_ACC);
    v[2] = ANO_Quantize(acc_ms2[2], ANO_LSB_ACC);
    v[3] = ANO_Quantize(gyr_dps[0], ANO_LSB_GYR);
    v[4] = ANO_Quantize(gyr_dps[1], ANO_LSB_GYR);
    v[5] = ANO_Quantize(gyr_dps[2], ANO_LSB_GYR);
    v[6] = (int16_t)shock;

    ANO_SendInt16s(ANO_FUN_FC_MOTION, v, 7u);
}

void ANO_SendFC_MagBaro(const int16_t mag[3], float alt_m, float temp_c,
                        uint8_t sta_bar, uint8_t sta_mag)
{
    int16_t v[7];

    v[0] = mag[0];
    v[1] = mag[1];
    v[2] = mag[2];
    v[3] = ANO_Quantize(alt_m, 100.0f);    /* 厘米 */
    v[4] = ANO_Quantize(temp_c, 100.0f);   /* 0.01 °C */
    v[5] = (int16_t)sta_bar;
    v[6] = (int16_t)sta_mag;

    ANO_SendInt16s(ANO_FUN_FC_ENV, v, 7u);
}

void ANO_SendFC_Attitude(float roll_deg, float pitch_deg, float yaw_deg)
{
    int16_t v[3];

    v[0] = ANO_Quantize(roll_deg, ANO_LSB_ATT);
    v[1] = ANO_Quantize(pitch_deg, ANO_LSB_ATT);
    v[2] = ANO_Quantize(yaw_deg, ANO_LSB_ATT);

    ANO_SendInt16s(ANO_FUN_FC_ATT, v, 3u);
}
