#ifndef __ANO_H
#define __ANO_H

#include <stdint.h>

/*
 * 匿名上位机 V7 协议（全部小端）：
 *
 *   0xAA | 目标地址 | 功能码 | 数据长度(字节) | 数据... | 和校验 | 附加校验
 *
 *   和校验  ：从 0xAA 开始到最后一个数据字节，逐字节累加，取低 8 位。
 *   附加校验：每累加一个字节，就把当前的和校验再累加一次，取低 8 位。
 *
 * 本文件实现两类帧：
 *
 *   1) 飞控固定帧 0x01 / 0x02 / 0x03
 *      对应上位机“波形显示”里 FC_ACC_*、FC_GYR_*、FC_MAG_*、FC_ATT_*
 *      这些通道。通道名和顺序是协议里写死的，所以“飞控状态”页的 3D 模型、
 *      罗盘、ROL/PIT/YAW 也都吃这几帧。
 *
 *   2) 用户自定义帧 0xF1（可选）
 *      内容自由，但要在上位机里手工把通道映射出来才能看见。
 *
 * 定点比例：显示值如果整体差 10 倍或 100 倍，改下面三个比例即可。
 */

/* 每 LSB 对应的物理量 */
#define ANO_LSB_ACC   100.0f   /* 0.01 m/s² */
#define ANO_LSB_GYR    10.0f   /* 0.1  °/s   */
#define ANO_LSB_ATT   100.0f   /* 0.01 °     */

void ANO_SendInt16s(uint8_t fun, const int16_t *values, uint8_t count);
void ANO_SendFloats(uint8_t fun, const float *values, uint8_t count);

/* 0x01：加速度(m/s²) + 角速度(°/s) + 震动标志 */
void ANO_SendFC_AccGyr(const float acc_ms2[3], const float gyr_dps[3], uint8_t shock);

/* 0x02：磁力原始值 + 气压高度(m) + 温度(°C) + 两个状态字 */
void ANO_SendFC_MagBaro(const int16_t mag[3], float alt_m, float temp_c,
                        uint8_t sta_bar, uint8_t sta_mag);

/* 0x03：姿态角（度） */
void ANO_SendFC_Attitude(float roll_deg, float pitch_deg, float yaw_deg);

#endif
