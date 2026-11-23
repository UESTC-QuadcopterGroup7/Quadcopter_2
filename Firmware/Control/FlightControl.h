#ifndef FLIGHT_CONTROL_H
#define FLIGHT_CONTROL_H

#include "PID.h"
#include "RC_Control.h"
#include "FlightControlConfig.h"

typedef enum { FC_ROLL = 0, FC_PITCH, FC_YAW, FC_AXIS_COUNT } FC_Axis_t;

/// @brief 飞控反馈数据结构体
typedef struct {
    float roll_deg, pitch_deg;
    float rate_dps[FC_AXIS_COUNT]; /* 机体轴，右滚/抬头/右转为正：gx、-gy、-gz。 */
    uint32_t timestamp_ms;        /* HAL_GetTick()，用于检测过期。 */
    uint32_t timestamp_cycles;    /* DWT->CYCCNT，差分后换算 dt，支持计数器回绕。 */
    uint32_t sequence;            /* 同一姿态和陀螺样本的发布序号。 */
    uint8_t valid;                /* 上电校准完成且本次读取/解算成功。 */
} FC_Feedback_t;

typedef enum {
    FC_STATUS_DISARMED = 0,
    FC_STATUS_ACTIVE,
    FC_STATUS_THROTTLE_OFF,
    FC_STATUS_RC_LOST,
    FC_STATUS_FEEDBACK_INVALID,
    FC_STATUS_FEEDBACK_STALE,
    FC_STATUS_ARM_TILT,
    FC_STATUS_EXCESS_TILT,
    FC_STATUS_BAD_TIMING,
    FC_STATUS_PID_ERROR
} FC_Status_t;

/// @brief 飞控运行状态结构体
typedef struct {
    RC_Control_t rc;
    PID_t rate_pid[FC_AXIS_COUNT];
    float rate_setpoint_dps[FC_AXIS_COUNT];
    float filtered_rate_dps[FC_AXIS_COUNT];
    float correction_us[FC_AXIS_COUNT];
    float dt_s;
    float tilt_deg;               /* 最近一次有效反馈的总倾角，0..180 deg。 */
    uint32_t clock_hz;
    uint32_t previous_cycles;
    uint32_t previous_sequence;
    FC_Status_t status;
    uint8_t running;
    uint8_t bench_fault_latched;  /* 无接收机测试启动后故障，复位前禁止重启。 */
    uint8_t tipover_latched;       /* 过倾角故障锁存；普通上锁或恢复信号不会清除。 */
    uint8_t tipover_clear_pending;
    uint32_t tipover_clear_start_ms;
} FC_Control_t;

/* 校验原始陀螺未接近量程饱和，转换为与混控一致的三轴正方向。 */
uint8_t FC_ConvertGyro(const int16_t gyro[FC_AXIS_COUNT], float rate_dps[FC_AXIS_COUNT]);
uint8_t FC_Control_Init(FC_Control_t *control, uint32_t cycle_clock_hz);

/* 一次调用包含遥控解码、解锁、反馈检查、外环、内环和电机混控。
 * 必须串行调用；motor 输出位于 control->rc.motor_us，顺序为 M1..M4。
 * 不重复积分同一个 sequence；无新样本时保留修正量并重新应用油门。
 * 反馈/时序异常会停机上锁，恢复后需要重新手势解锁。
 * 无接收机台架模式下，启动后的故障停机锁存至复位；没有遥控恢复手势。
 * 总倾角达到停机阈值时锁存故障。扶正至解锁倾角内，油门为零、横滚/俯仰
 * 居中、偏航左满持续 FC_TIPOVER_CLEAR_HOLD_MS 才解除；之后仍须手势解锁。
 */
void FC_Control_Update(FC_Control_t *control, const RC_Input_t *input,
                       const FC_Feedback_t *feedback, uint32_t now_ms);

#endif
