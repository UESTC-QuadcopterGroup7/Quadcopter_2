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
    RC_MOTOR_REAR_RIGHT = 0, /* 右后电机 M1 */
    RC_MOTOR_FRONT_RIGHT,    /* 右前电机 M2 */
    RC_MOTOR_FRONT_LEFT,     /* 左前电机 M3 */
    RC_MOTOR_REAR_LEFT,      /* 左后电机 M4 */
    RC_MOTOR_COUNT           /* 电机总数，用于数组长度和遍历 */
} RC_MotorIndex_t;

/* 接收机采集快照，按通道下标存放脉宽和更新时间。 */
typedef struct {
    uint16_t pulse_us[RC_CHANNEL_COUNT];   /* 各通道最近一次采集的 PWM 脉宽（µs） */
    uint32_t updated_ms[RC_CHANNEL_COUNT]; /* 各通道的 HAL_GetTick() 更新时间（ms） */
    uint8_t valid_mask;                    /* 第 i 位为 1 表示通道 i 的采集数据有效 */
} RC_Input_t;

/* 遥控信号解码后的归一化摇杆指令。 */
typedef struct {
    float throttle;  /* 0..1；回中及下半程为 0 */
    float roll;      /* -1..1；右滚为正 */
    float pitch;     /* -1..1；抬头为正 */
    float yaw;       /* -1..1；右转为正 */
} RC_Command_t;

/* 供飞控闭环使用的油门和姿态目标。 */
typedef struct {
    float throttle;       /* 归一化油门，范围 0..1 */
    float roll_deg;       /* 目标横滚角（度） */
    float pitch_deg;      /* 目标俯仰角（度） */
    float yaw_rate_dps;   /* 目标偏航角速度（度/秒），松杆时目标为 0 */
} RC_Setpoint_t;

/* 遥控及台架测试的运行状态。 */
typedef struct {
    RC_Command_t command;              /* 当前归一化控制指令 */
    RC_Setpoint_t setpoint;            /* 当前飞控目标 */
    uint16_t motor_us[RC_MOTOR_COUNT]; /* 各电机的输出 PWM 脉宽（µs） */
    uint32_t gesture_start_ms;         /* 手势保持或台架等待的起始时间（ms） */
    uint8_t armed;                     /* 解锁状态，1 表示已解锁 */
    uint8_t signal_valid;              /* 指令有效标志，来源为遥控输入或本地台架指令 */
    uint8_t gesture;                   /* 遥控模式为手势状态，台架模式为测试进度 */
} RC_Control_t;

/* 纯计算模块，不访问 HAL/RTOS。调用方串行调用并提供一致的接收机快照。 */
uint8_t RC_Decode(const RC_Input_t *input, uint32_t now_ms, RC_Command_t *command);
void RC_MakeSetpoint(const RC_Command_t *command, RC_Setpoint_t *setpoint);

/* T/R/P/Y 单位均为 us；R 右滚、P 抬头、Y 右转为正。
 * 对角同向旋转是偏航混控成立的前提。饱和时同比缩放差速，再平移公共油门。
 * FlightControl 使用 PID 输出调用此函数；调用方负责解锁、失联及回中停机。
 */
void RC_Mix(float throttle_us, float roll_us, float pitch_us, float yaw_us,
            uint16_t motor_us[RC_MOTOR_COUNT]);
void RC_Control_Init(RC_Control_t *control);
void RC_Control_Disarm(RC_Control_t *control);

/* 只生成遥控目标和解锁状态，motor_us 始终置停止值。
 * RC_RECEIVER_ENABLED=0 时忽略 input，改为水平目标、延时启动、固定基础油门
 * 的限时台架测试；故障锁存由 FlightControl 处理，停止后需复位重试。
 * 闭环输出由 FlightControl.c 生成，不再将摇杆直接混控到电机。
 * 回中油门 + 偏航右打满保持 1s 解锁；回中油门 + 偏航左打满保持 1s 上锁。
 * 解锁手势还要求横滚/俯仰居中；任一通道无效或超时立即上锁。
 */
void RC_Control_Update(RC_Control_t *control, const RC_Input_t *input, uint32_t now_ms);

#endif
