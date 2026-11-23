#ifndef PID_H
#define PID_H

#include <stdint.h>

typedef struct {
    float kp, ki, kd;
    float integral_limit;       /* I 项的输出单位限幅，不是误差积分的限幅。 */
    float output_limit;         /* 对称输出限幅，必须 > 0。 */
    float derivative_cutoff_hz; /* 一阶微分低通；0 表示不滤波。 */
} PID_Config_t;

typedef struct {
    PID_Config_t config;
    float error;
    float p_term, i_term, d_term;
    float output;
    float previous_measurement;
    float derivative;
    uint8_t initialized;
    uint8_t configured;
} PID_t;

/* 纯 C、无 HAL/RTOS/堆分配。成功返回 1，非法配置返回 0。 */
uint8_t PID_Init(PID_t *pid, const PID_Config_t *config);
void PID_Reset(PID_t *pid); /* 保留配置，清除历史量和输出。 */

/* dt 单位 s，合法范围 (0, 1]；D 对测量值微分，避免目标阶跃产生微分冲击。
 * 积分使用条件积分抗饱和；allow_integral=0 冻结 I，仍更新 P/D。
 * 成功返回 1；非法输入返回 0 并清空历史与输出。
 */
uint8_t PID_Update(PID_t *pid, float setpoint, float measurement, float dt,
                   uint8_t allow_integral);

/* 根据执行器真正实现的输出回算积分；tracking_gain 单位 1/s。
 * 由调用方在混控后调用；不会改变本次已经发出的 pid->output。
 */
void PID_TrackOutput(PID_t *pid, float applied_output, float tracking_gain, float dt);

#endif
