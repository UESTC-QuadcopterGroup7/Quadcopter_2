/*
 * 飞行控制模块，根据控制目标和姿态反馈运行横滚、俯仰角度外环及三轴角速度 PID。
 * 生成四路电机混控输出，并在遥控失联、反馈异常或倾角过大时停机。
 */
#include "FlightControl.h"
#include "GY86.h"
#include <float.h>
#include <math.h>
#include <string.h>

/* 角度与弧度转换 */
#define FC_DEG_TO_RAD 0.01745329251994329577f
#define FC_RAD_TO_DEG 57.29577951308232087680f

/// @brief 检查浮点数是否为有限值
/// @param value 要检查的浮点数
/// @return 1 表示是有限值，0 表示不是有限值
static uint8_t Finite(float value)
{
    return (uint8_t)(value >= -FLT_MAX && value <= FLT_MAX);
}

/// @brief 限制浮点数的范围
/// @param value 要限制的浮点数
/// @param magnitude 限制的幅度
/// @return 限制后的浮点数
static float Limit(float value, float magnitude)
{
    if (value > magnitude) return magnitude;
    if (value < -magnitude) return -magnitude;
    return value;
}

/// @brief 将陀螺仪原始读数转换为角速度（度/秒）
/// @param gyro 陀螺仪原始读数数组
/// @param rate_dps 转换后的角速度数组（度/秒）
/// @return 1 表示转换成功，0 表示转换失败
uint8_t FC_ConvertGyro(const int16_t gyro[FC_AXIS_COUNT], float rate_dps[FC_AXIS_COUNT])
{
    uint8_t i;
    if (gyro == 0 || rate_dps == 0) return 0u;
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        if (gyro[i] >= 32760 || gyro[i] <= -32760) return 0u;
    }
    rate_dps[FC_ROLL] = (float)gyro[0] / MPU6050_GYRO_LSB_PER_DPS;
    rate_dps[FC_PITCH] = -(float)gyro[1] / MPU6050_GYRO_LSB_PER_DPS;
    rate_dps[FC_YAW] = -(float)gyro[2] / MPU6050_GYRO_LSB_PER_DPS;
    return 1u;
}

/// @brief 重置控制回路
/// @param control 控制结构体指针
static void ResetLoops(FC_Control_t *control)
{
    uint8_t i;
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        /* 保留该轴的 PID 增益、限幅、滤波配置和已配置标志。
         * 清空误差、积分项、微分历史和输出，使下次更新从新采样开始。
         */
        PID_Reset(&control->rate_pid[i]);
        control->rate_setpoint_dps[i] = 0.0f;
        control->filtered_rate_dps[i] = 0.0f;
        control->correction_us[i] = 0.0f;
    }
    control->running = 0u;
    control->dt_s = 0.0f;
}

/// @brief 报告故障
/// @param control 
/// @param status 
static void Fault(FC_Control_t *control, FC_Status_t status)
{
#if !RC_RECEIVER_ENABLED
    if (control->rc.armed != 0u || control->running != 0u) {
        control->bench_fault_latched = 1u;
    }
#endif
    RC_Control_Disarm(&control->rc); // 上锁，不采用遥控器控制
    ResetLoops(control); // 清除 PID 历史量和输出
    control->tipover_clear_pending = 0u;
    control->status = status;
}

/// @brief 初始化飞控状态和横滚、俯仰、偏航三轴角速度 PID。
/// @details 清零飞控状态，将遥控控制器设为上锁并设置四路停机脉宽，
///          然后加载各轴的 PID 增益、限幅和微分滤波参数。
/// @param[out] control 待初始化的飞控状态结构体。
/// @param[in] cycle_clock_hz DWT 周期计数器的时钟频率（Hz），用于将采样间的周期差换算成秒。
/// @return 成功返回 1。指针为空、时钟频率为 0 或任一轴的 PID 初始化失败时返回 0。
uint8_t FC_Control_Init(FC_Control_t *control, uint32_t cycle_clock_hz)
{
    const PID_Config_t configs[FC_AXIS_COUNT] = {
        {FC_ROLL_RATE_KP, FC_ROLL_RATE_KI, FC_ROLL_RATE_KD,
         FC_RP_INTEGRAL_LIMIT_US, FC_RP_OUTPUT_LIMIT_US, FC_DERIVATIVE_CUTOFF_HZ},
        {FC_PITCH_RATE_KP, FC_PITCH_RATE_KI, FC_PITCH_RATE_KD,
         FC_RP_INTEGRAL_LIMIT_US, FC_RP_OUTPUT_LIMIT_US, FC_DERIVATIVE_CUTOFF_HZ},
        {FC_YAW_RATE_KP, FC_YAW_RATE_KI, FC_YAW_RATE_KD,
         FC_YAW_INTEGRAL_LIMIT_US, FC_YAW_OUTPUT_LIMIT_US, FC_DERIVATIVE_CUTOFF_HZ}
    };
    uint8_t i;
    if (control == 0) return 0u;
    memset(control, 0, sizeof(*control));
    RC_Control_Init(&control->rc);
    if (cycle_clock_hz == 0u) return 0u;
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        if (!PID_Init(&control->rate_pid[i], &configs[i])) return 0u;
    }
    control->clock_hz = cycle_clock_hz;
    return 1u;
}

/// @brief 检查反馈数据是否有效
/// @param feedback 反馈数据指针
/// @return 1 表示数据有效，0 表示数据无效
static uint8_t FeedbackValid(const FC_Feedback_t *feedback)
{
    uint8_t i;
    if (feedback == 0 || feedback->valid == 0u ||
        !Finite(feedback->roll_deg) || !Finite(feedback->pitch_deg)) return 0u;
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        if (!Finite(feedback->rate_dps[i]) || fabsf(feedback->rate_dps[i]) > 2000.0f) return 0u;
    }
    return 1u;
}

/// @brief 计算向上的余弦值
/// @param feedback 反馈数据指针
/// @return 向上的余弦值
static float UpwardCosine(const FC_Feedback_t *feedback)
{
    /* Rz(-yaw)*Ry(-pitch)*Rx(roll) 的 R33，与航向无关。
     * 使用总倾角也能覆盖 roll=60、pitch=60 这类两个轴均未达到阈值的姿态。
     * 这里使用融合姿态，不用瞬时加速度 Z 的正负判断翻转。
     */
    float cosine = cosf(feedback->roll_deg * FC_DEG_TO_RAD) *
                   cosf(feedback->pitch_deg * FC_DEG_TO_RAD);
    return Limit(cosine, 1.0f);
}

/// @brief 机身倾斜过大触发保护后，让电机保持停止，直到满足解除条件。
/// @details 扶正机身（默认倾角不超过 15°），油门归零，横滚和俯仰摇杆回中，
///          偏航摇杆向左接近打满。以上条件须同时保持 1 秒（默认值）。
///          任一条件中断就重新计时。退出保护后，仍需正常解锁才能启动电机。
/// @param[in,out] control 飞控状态，保存保护标志和计时信息。
/// @param[in] upward_cosine 机身倾角的余弦，越接近 1 表示机身越接近水平。
/// @param[in] now_ms 当前系统时间（ms），用于计算条件保持了多久。
static void HoldTipoverFault(FC_Control_t *control, float upward_cosine, uint32_t now_ms)
{
    const RC_Command_t *command = &control->rc.command;
    RC_Control_Disarm(&control->rc);
    ResetLoops(control);
    control->status = FC_STATUS_EXCESS_TILT;

    /* 各条件须同时满足。偏航向左打杆达到归一化阈值 -0.9 才开始计时。 */
    if (upward_cosine >= cosf(FC_ARM_MAX_TILT_DEG * FC_DEG_TO_RAD) &&
        command->throttle <= 0.0f && command->roll >= -0.1f && command->roll <= 0.1f &&
        command->pitch >= -0.1f && command->pitch <= 0.1f && command->yaw <= -0.9f) {
        if (control->tipover_clear_pending == 0u) {
            control->tipover_clear_pending = 1u;
            control->tipover_clear_start_ms = now_ms;
        } else if ((uint32_t)(now_ms - control->tipover_clear_start_ms) >= FC_TIPOVER_CLEAR_HOLD_MS) {
            control->tipover_latched = 0u;
            control->tipover_clear_pending = 0u;
            control->status = FC_STATUS_DISARMED;
        }
    } else {
        control->tipover_clear_pending = 0u;
    }
}

/// @brief 计算供内环 PID 使用的三轴机体角速度目标。
/// @details 将横滚角和俯仰角的误差乘以各自的外环比例增益，得到目标欧拉角速度。
///          偏航直接取设定的偏航角速度。根据当前姿态将三轴目标转换到机体系并限幅。
/// @param[in,out] control 提供姿态控制目标，并接收 rate_setpoint_dps 中的结果（度/秒）。
/// @param[in] feedback 提供当前横滚角和俯仰角（度），用于计算角度误差和坐标转换。
static void RateTargets(FC_Control_t *control, const FC_Feedback_t *feedback)
{
    float roll = feedback->roll_deg * FC_DEG_TO_RAD;
    float pitch = feedback->pitch_deg * FC_DEG_TO_RAD;
    float roll_dot = Limit(FC_ROLL_ANGLE_KP * (control->rc.setpoint.roll_deg - feedback->roll_deg),
                           FC_MAX_RP_RATE_DPS);
    float pitch_dot = Limit(FC_PITCH_ANGLE_KP * (control->rc.setpoint.pitch_deg - feedback->pitch_deg),
                            FC_MAX_RP_RATE_DPS);
    float yaw_dot = control->rc.setpoint.yaw_rate_dps;
    /* 欧拉角速度转机体角速度，避免倾斜时把二者直接等同。
     * 符号与 Quaternion.h 的 Rz(-yaw)*Ry(-pitch)*Rx(roll) 一致。 */
    control->rate_setpoint_dps[FC_ROLL] = Limit(roll_dot - yaw_dot * sinf(pitch),
                                               FC_MAX_RP_RATE_DPS);
    control->rate_setpoint_dps[FC_PITCH] = Limit(pitch_dot * cosf(roll) +
                                                yaw_dot * sinf(roll) * cosf(pitch),
                                                FC_MAX_RP_RATE_DPS);
    control->rate_setpoint_dps[FC_YAW] = Limit(-pitch_dot * sinf(roll) +
                                              yaw_dot * cosf(roll) * cosf(pitch),
                                              RC_MAX_YAW_RATE_DPS);
}

/// @brief 用混控后的输出修正三轴 PID 的积分项，减轻积分饱和。
/// @details 根据四路电机 PWM 的差值，反算混控实际分配给横滚、俯仰和偏航的修正量（微秒）。
///          PID_TrackOutput() 将这些修正量与各轴的 PID 输出比较，按差值回算积分项。
/// @param[in,out] control 提供混控后的 motor_us 和采样间隔 dt_s，并保存更新后的三轴 PID 状态。
static void TrackMixer(FC_Control_t *control)
{
    const uint16_t *m = control->rc.motor_us;
    float applied[FC_AXIS_COUNT];
    uint8_t i;
    applied[FC_ROLL] = ((float)m[2] + m[3] - m[0] - m[1]) * 0.25f;
    applied[FC_PITCH] = ((float)m[1] + m[2] - m[0] - m[3]) * 0.25f;
    applied[FC_YAW] = ((float)m[1] + m[3] - m[0] - m[2]) *
                      (RC_FRONT_LEFT_CW ? 0.25f : -0.25f);
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        PID_TrackOutput(&control->rate_pid[i], applied[i], FC_MIXER_TRACKING_GAIN, control->dt_s);
    }
}

/// @brief 执行一轮飞控更新，生成四路电机待输出的 PWM 脉宽。
/// @details 更新遥控或台架指令，检查反馈有效性、超时和机身倾角。
///          检查通过且已解锁、油门大于零时，根据新反馈更新三轴闭环，并进行电机混控。
///          上锁、零油门或故障时，将四路输出保持在停机值。
/// @param[in,out] control 飞控运行状态，四路 PWM 脉宽写入 rc.motor_us（微秒）。
/// @param[in] input 接收机输入快照，台架模式下可传空指针。
/// @param[in] feedback 飞控反馈快照，包含姿态角、三轴角速度、有效标志和采样时间。
/// @param[in] now_ms 当前 HAL_GetTick() 时间戳（毫秒），用于超时和状态计时。
void FC_Control_Update(FC_Control_t *control, const RC_Input_t *input,
                       const FC_Feedback_t *feedback, uint32_t now_ms)
{
    uint8_t i, new_sample, allow_integral, was_armed;
    float upward_cosine;
    if (control == 0) return;
#if !RC_RECEIVER_ENABLED
    if (control->bench_fault_latched != 0u) { /* 台架故障已锁存，保持上锁和停机。 */
        RC_Control_Disarm(&control->rc); // 上锁，不采用遥控器控制
        ResetLoops(control); // 清除 PID 历史量和输出
        return; /* 保留原始故障状态；只能复位重试，不因反馈恢复自动重启。 */
    }
#endif
    was_armed = control->rc.armed;
    RC_Control_Update(&control->rc, input, now_ms); // 更新遥控器或台架指令
    if (control->rc.signal_valid == 0u) { Fault(control, FC_STATUS_RC_LOST); return; }
    if (!FeedbackValid(feedback)) { Fault(control, FC_STATUS_FEEDBACK_INVALID); return; }
    if ((uint32_t)(now_ms - feedback->timestamp_ms) >= FC_FEEDBACK_TIMEOUT_MS) {
        Fault(control, FC_STATUS_FEEDBACK_STALE);
        return;
    }
    upward_cosine = UpwardCosine(feedback);
    control->tilt_deg = acosf(upward_cosine) * FC_RAD_TO_DEG;
    if (upward_cosine <= cosf(FC_STOP_MAX_TILT_DEG * FC_DEG_TO_RAD)) {
        control->tipover_latched = 1u;
        Fault(control, FC_STATUS_EXCESS_TILT);
        return;
    }
    if (control->tipover_latched != 0u) {
        HoldTipoverFault(control, upward_cosine, now_ms);
        return;
    }
    if ((was_armed == 0u || control->rc.armed == 0u) &&
        upward_cosine < cosf(FC_ARM_MAX_TILT_DEG * FC_DEG_TO_RAD)) {
        Fault(control, FC_STATUS_ARM_TILT);
        return;
    }
    if (control->rc.armed == 0u || control->rc.command.throttle <= 0.0f) {
        ResetLoops(control);
        control->status = control->rc.armed ? FC_STATUS_THROTTLE_OFF : FC_STATUS_DISARMED;
        return;
    }
    new_sample = (uint8_t)(control->running == 0u || feedback->sequence != control->previous_sequence);
    allow_integral = (uint8_t)(control->rc.command.throttle >= FC_INTEGRAL_MIN_THROTTLE);
    if (new_sample != 0u) {
        float dt = (float)FC_CONTROL_PERIOD_MS * 0.001f;
        float alpha;
        if (control->clock_hz == 0u) { Fault(control, FC_STATUS_BAD_TIMING); return; }
        if (control->running != 0u) {
            dt = (float)(uint32_t)(feedback->timestamp_cycles - control->previous_cycles) /
                 (float)control->clock_hz;
        }
        if (!Finite(dt) || dt < FC_DT_MIN_S || dt > FC_DT_MAX_S) {
            Fault(control, FC_STATUS_BAD_TIMING);
            return;
        }
        control->dt_s = dt;
        alpha = dt / (1.0f / (6.28318530718f * FC_GYRO_CUTOFF_HZ) + dt);
        RateTargets(control, feedback);
        for (i = 0u; i < FC_AXIS_COUNT; ++i) {
            if (control->running == 0u) control->filtered_rate_dps[i] = feedback->rate_dps[i];
            else control->filtered_rate_dps[i] += alpha *
                    (feedback->rate_dps[i] - control->filtered_rate_dps[i]);
            if (!PID_Update(&control->rate_pid[i], control->rate_setpoint_dps[i],
                             control->filtered_rate_dps[i], dt, allow_integral)) {
                Fault(control, FC_STATUS_PID_ERROR);
                return;
            }
            control->correction_us[i] = control->rate_pid[i].output;
        }
        control->previous_cycles = feedback->timestamp_cycles;
        control->previous_sequence = feedback->sequence;
        control->running = 1u;
    }
    RC_Mix((float)RC_MOTOR_MIN_US + control->rc.command.throttle *
           (float)(RC_MOTOR_MAX_US - RC_MOTOR_MIN_US),
           control->correction_us[FC_ROLL], control->correction_us[FC_PITCH],
           control->correction_us[FC_YAW], control->rc.motor_us);
    if (new_sample != 0u && allow_integral != 0u) TrackMixer(control);
    control->status = FC_STATUS_ACTIVE;
}
