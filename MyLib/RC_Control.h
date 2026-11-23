#ifndef RC_CONTROL_H
#define RC_CONTROL_H

#include <stdint.h>
#include "RC_Config.h"

/* 数组下标 + 1 = BLDC_SetThrottle_us() 的 idx，不是排针从左到右的编号。
 * 机头为 GY86 +X，俯视：
 *       左前 M3 CW       M2 CCW 右前
 *                   ^ 前
 *       左后 M4 CCW      M1 CW  右后
 * PCB 槽位从左到右：M4、M3、M2、M1。
 */
typedef enum {
    RC_MOTOR_REAR_RIGHT = 0,
    RC_MOTOR_FRONT_RIGHT,
    RC_MOTOR_FRONT_LEFT,
    RC_MOTOR_REAR_LEFT,
    RC_MOTOR_COUNT
} RC_MotorIndex_t;

typedef struct {
    uint16_t pulse_us[RC_CHANNEL_COUNT];
    uint32_t updated_ms[RC_CHANNEL_COUNT]; /* HAL_GetTick() 时间戳 */
    uint8_t valid_mask;
} RC_Input_t;

typedef struct {
    float throttle;  /* 0..1；回中及下半程为 0 */
    float roll;      /* -1..1；右滚为正 */
    float pitch;     /* -1..1；抬头为正 */
    float yaw;       /* -1..1；右转为正 */
} RC_Command_t;

typedef struct {
    float throttle;       /* 0..1 */
    float roll_deg;       /* 目标横滚角，不是测量值 */
    float pitch_deg;      /* 目标俯仰角，不是测量值 */
    float yaw_rate_dps;   /* 目标偏航角速度，松杆为 0，不指定绝对航向 */
} RC_Setpoint_t;

typedef struct {
    RC_Command_t command;
    RC_Setpoint_t setpoint;
    uint16_t motor_us[RC_MOTOR_COUNT];
    uint32_t gesture_start_ms;
    uint8_t armed;
    uint8_t signal_valid;
    uint8_t gesture;
} RC_Control_t;

/* 纯计算模块，不访问 HAL/RTOS。调用方串行调用并提供一致的接收机快照。 */
uint8_t RC_Decode(const RC_Input_t *input, uint32_t now_ms, RC_Command_t *command);
void RC_MakeSetpoint(const RC_Command_t *command, RC_Setpoint_t *setpoint);

/* T/R/P/Y 单位均为 us；R 右滚、P 抬头、Y 右转为正。
 * 对角同向旋转是偏航混控成立的前提。饱和时同比缩放差速，再平移公共油门。
 * 可供后续 PID 输出复用；调用方仍须负责解锁、失联及回中停机。
 */
void RC_Mix(float throttle_us, float roll_us, float pitch_us, float yaw_us,
            uint16_t motor_us[RC_MOTOR_COUNT]);
void RC_Control_Init(RC_Control_t *control);

/* 当前为开环差速验证：遥控输入直接产生混控修正量，尚未使用姿态反馈。
 * 回中油门 + 偏航右打满保持 1s 解锁；回中油门 + 偏航左打满保持 1s 上锁。
 * 解锁手势还要求横滚/俯仰居中；任一通道无效或超时立即上锁。
 */
void RC_Control_Update(RC_Control_t *control, const RC_Input_t *input, uint32_t now_ms);

#endif
