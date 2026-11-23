/*
 * Radio Control
 * 负责遥控信号解码、飞控目标生成、解锁与失联处理，以及台架测试和四路电机混控。
 */

#include "RC_Control.h"
#include <float.h>
#include <string.h>

#define RC_GESTURE_NONE     0u
#define RC_GESTURE_ARM      1u
#define RC_GESTURE_DISARM   2u

/// @brief 将值限制在指定范围内
/// @param value 要限制的值
/// @param low 最小值
/// @param high 最大值
/// @return 限制后的值
static float Clamp(float value, float low, float high)
{
    if (value < low) return low;
    if (value > high) return high;
    return value;
}

/// @brief 检查值是否为有限值
/// @param value 要检查的值
/// @return 如果是有限值则返回 1，否则返回 0
static uint8_t Finite(float value)
{
    return (uint8_t)(value >= -FLT_MAX && value <= FLT_MAX);
}

/// @brief 停止所有电机，只是更新了电机 PWM 值数组，没有直接控制硬件
/// @param motor_us 电机 PWM 值数组
static void StopMotors(uint16_t motor_us[RC_MOTOR_COUNT])
{
    uint8_t i;
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
        motor_us[i] = RC_MOTOR_OFF_US;
    }
}

/// @brief 将横滚、俯仰或偏航通道的 PWM 脉宽转换为归一化摇杆输入。
/// @details 先将脉宽限制在配置范围内。中位死区内（含边界）返回 0，
///          死区外按两侧各自的有效行程线性映射。
/// @param pulse_us 遥控接收机的 PWM 脉宽，单位为微秒（µs）。
/// @return [-1.0, 1.0]，最小脉宽对应 -1.0，最大脉宽对应 1.0。
static float DecodeAxis(uint16_t pulse_us)
{
    float pulse = Clamp((float)pulse_us, (float)RC_PWM_MIN_US, (float)RC_PWM_MAX_US);
    if (pulse > (float)(RC_PWM_MID_US + RC_DEADBAND_US)) {
        return (pulse - (float)(RC_PWM_MID_US + RC_DEADBAND_US)) /
               (float)(RC_PWM_MAX_US - RC_PWM_MID_US - RC_DEADBAND_US);
    }
    if (pulse < (float)(RC_PWM_MID_US - RC_DEADBAND_US)) {
        return (pulse - (float)(RC_PWM_MID_US - RC_DEADBAND_US)) /
               (float)(RC_PWM_MID_US - RC_PWM_MIN_US - RC_DEADBAND_US);
    }
    return 0.0f;
}

/// @brief 解码遥控信号
/// @param input 遥控输入结构体
/// @param now_ms 当前时间（毫秒）
/// @param command 解码后的命令结构体
/// @return 解码成功返回 1，失败返回 0
uint8_t RC_Decode(const RC_Input_t *input, uint32_t now_ms, RC_Command_t *command)
{
    uint8_t i;
    float throttle_pulse;
    if (command == 0) return 0u;
    memset(command, 0, sizeof(*command));
    if (input == 0 || (input->valid_mask & RC_ALL_CHANNELS_MASK) != RC_ALL_CHANNELS_MASK) {
        return 0u;
    }
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        if (input->pulse_us[i] < RC_VALID_MIN_US || input->pulse_us[i] > RC_VALID_MAX_US ||
            (uint32_t)(now_ms - input->updated_ms[i]) >= RC_SIGNAL_TIMEOUT_MS) {
            return 0u;
        }
    }

    command->roll = DecodeAxis(input->pulse_us[RC_ROLL_CHANNEL]) * (float)RC_ROLL_DIRECTION;
    command->pitch = DecodeAxis(input->pulse_us[RC_PITCH_CHANNEL]) * (float)RC_PITCH_DIRECTION;
    command->yaw = DecodeAxis(input->pulse_us[RC_YAW_CHANNEL]) * (float)RC_YAW_DIRECTION;
    throttle_pulse = Clamp((float)input->pulse_us[RC_THROTTLE_CHANNEL],
                           (float)RC_PWM_MIN_US, (float)RC_PWM_MAX_US);
#if RC_THROTTLE_DIRECTION == -1
    throttle_pulse = (float)(RC_PWM_MIN_US + RC_PWM_MAX_US) - throttle_pulse;
#endif
    command->throttle = Clamp((throttle_pulse - (float)RC_THROTTLE_START_US) /
                              (float)(RC_PWM_MAX_US - RC_THROTTLE_START_US), 0.0f, 1.0f);
    return 1u;
}

/// @brief 根据遥控命令生成飞控目标
/// @param command 遥控命令
/// @param setpoint 飞控目标
void RC_MakeSetpoint(const RC_Command_t *command, RC_Setpoint_t *setpoint)
{
    if (setpoint == 0) return;
    memset(setpoint, 0, sizeof(*setpoint));
    if (command == 0) return;
    setpoint->throttle = command->throttle;
#if !RC_TUNING_LOCK_ROLL
    setpoint->roll_deg = command->roll * RC_MAX_ROLL_DEG;
#endif
#if !RC_TUNING_LOCK_PITCH
    setpoint->pitch_deg = command->pitch * RC_MAX_PITCH_DEG;
#endif
#if !RC_TUNING_LOCK_YAW
    setpoint->yaw_rate_dps = command->yaw * RC_MAX_YAW_RATE_DPS;
#endif
}

/// @brief 将基础油门和三轴修正量混合为四路电机 PWM 脉宽。
/// @details 差速跨度超出允许范围时等比缩小差速，再按需整体平移四路输出。
///          输入含非有限值或基础油门不高于最小脉宽时，四路均设为停机脉宽。
/// @param[in] throttle_us 四路电机共用的基础油门脉宽（µs）。
/// @param[in] roll_us 横滚修正量（µs），右滚为正。
/// @param[in] pitch_us 俯仰修正量（µs），抬头为正。
/// @param[in] yaw_us 偏航修正量（µs），右转为正。
/// @param[out] motor_us 按 RC_MotorIndex_t 顺序写入四路电机的 PWM 脉宽（µs）。
void RC_Mix(float throttle_us, float roll_us, float pitch_us, float yaw_us,
            uint16_t motor_us[RC_MOTOR_COUNT])
{
    float correction[RC_MOTOR_COUNT];
    const float range = (float)(RC_MOTOR_MAX_US - RC_MOTOR_MIN_US);
    float minimum, maximum, scale = 1.0f, shift = 0.0f;
    uint8_t i;
    if (motor_us == 0) return;
    StopMotors(motor_us);
    if (!Finite(throttle_us) || !Finite(roll_us) || !Finite(pitch_us) || !Finite(yaw_us) ||
        throttle_us <= (float)RC_MOTOR_MIN_US) {
        return;
    }
    throttle_us = Clamp(throttle_us, (float)RC_MOTOR_MIN_US, (float)RC_MOTOR_MAX_US);
    roll_us = Clamp(roll_us, -range, range);
    pitch_us = Clamp(pitch_us, -range, range);
    yaw_us = Clamp(yaw_us, -range, range);
#if RC_FRONT_LEFT_CW == 0
    yaw_us = -yaw_us;
#endif

    /* 已确认的通道位置：M1 右后、M2 右前、M3 左前、M4 左后。 */
    correction[RC_MOTOR_REAR_RIGHT]  = -roll_us - pitch_us - yaw_us;
    correction[RC_MOTOR_FRONT_RIGHT] = -roll_us + pitch_us + yaw_us;
    correction[RC_MOTOR_FRONT_LEFT]  =  roll_us + pitch_us - yaw_us;
    correction[RC_MOTOR_REAR_LEFT]   =  roll_us - pitch_us + yaw_us;

    minimum = maximum = correction[0];
    for (i = 1u; i < RC_MOTOR_COUNT; ++i) {
        if (correction[i] < minimum) minimum = correction[i];
        if (correction[i] > maximum) maximum = correction[i];
    }
    if (maximum - minimum > range) {
        scale = range / (maximum - minimum);
    }
    minimum = throttle_us + minimum * scale;
    maximum = throttle_us + maximum * scale;
    if (maximum > (float)RC_MOTOR_MAX_US) {
        shift = (float)RC_MOTOR_MAX_US - maximum;
    }
    if (minimum + shift < (float)RC_MOTOR_MIN_US) {
        shift += (float)RC_MOTOR_MIN_US - (minimum + shift);
    }
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
        float pulse = Clamp(throttle_us + correction[i] * scale + shift,
                            (float)RC_MOTOR_MIN_US, (float)RC_MOTOR_MAX_US);
        motor_us[i] = (uint16_t)(pulse + 0.5f);
    }
}

/// @brief 初始化 RC 控制器
/// @param control 
void RC_Control_Init(RC_Control_t *control)
{
    if (control == 0) return;
    memset(control, 0, sizeof(*control));
    StopMotors(control->motor_us);
}


/// @brief 将 RC 控制器设为上锁状态。
/// @details 清除解锁标志、手势状态与计时起点，并将四路电机的输出脉宽设为 RC_MOTOR_OFF_US。
/// @param[in,out] control 待上锁的 RC 控制器。传入空指针时直接返回。
void RC_Control_Disarm(RC_Control_t *control)
{
    if (control == 0) return;
    control->armed = 0u; // 上锁
    control->gesture = RC_GESTURE_NONE;
    control->gesture_start_ms = 0u; // 清除手势计时起点
    StopMotors(control->motor_us);
}

/// @brief 更新控制目标、指令有效状态和解锁状态。
/// @details 遥控模式下，解码接收机信号并处理解锁、上锁手势，信号无效时上锁。
///          台架模式下，保持三轴目标为零，按等待时间和运行时限更新解锁状态与基础油门。
///          本函数先将四路待输出脉宽设为停机值，后续混控由 FlightControl 处理。
/// @param[in,out] control 待更新的 RC 控制器状态，传入空指针时直接返回。
/// @param[in] input 接收机快照，含各通道脉宽、更新时间和有效位。台架模式下可传空指针。
/// @param[in] now_ms 当前系统时间（毫秒），用于信号超时、手势保持和台架计时。
void RC_Control_Update(RC_Control_t *control, const RC_Input_t *input, uint32_t now_ms)
{
#if RC_RECEIVER_ENABLED
// 遥控器模式
    uint8_t gesture = RC_GESTURE_NONE;
    if (control == 0) return;
    if (RC_Decode(input, now_ms, &control->command) == 0u) {
        RC_Control_Init(control); /* 失联后重新收到信号，也必须重新手势解锁。 */
        return;
    }
    control->signal_valid = 1u;
    RC_MakeSetpoint(&control->command, &control->setpoint);
    StopMotors(control->motor_us);

    if (control->command.throttle <= 0.0f) {
        if (control->armed != 0u && control->command.yaw <= -0.9f) {
            gesture = RC_GESTURE_DISARM;
        } else if (control->armed == 0u && control->command.yaw >= 0.9f &&
                   control->command.roll >= -0.1f && control->command.roll <= 0.1f &&
                   control->command.pitch >= -0.1f && control->command.pitch <= 0.1f) {
            gesture = RC_GESTURE_ARM;
        }
    }
    if (gesture == RC_GESTURE_NONE) {
        control->gesture = RC_GESTURE_NONE;
    } else if (gesture != control->gesture) {
        control->gesture = gesture;
        control->gesture_start_ms = now_ms;
    } else if ((uint32_t)(now_ms - control->gesture_start_ms) >= RC_ARM_HOLD_MS) {
        control->armed = (uint8_t)(gesture == RC_GESTURE_ARM);
        control->gesture = RC_GESTURE_NONE;
    }

    /* 电机保持停止值，只有 FlightControl 完成反馈检查与 PID 后才写入混控结果。 */
#else
//台架模式
    (void)input;
    if (control == 0) return;
    memset(&control->command, 0, sizeof(control->command));
    memset(&control->setpoint, 0, sizeof(control->setpoint));
    StopMotors(control->motor_us);
    /* signal_valid 在此表示本地测试指令有效，不代表收到遥控信号。
     * gesture: 0=未开始等待，1=等待/运行，2=本次测试结束。
     * 启动前 FC 故障会通过 Disarm 重置等待，要求重新连续等待。
     */
    control->signal_valid = 1u;
    control->armed = 0u;
    if (control->gesture == 0u) {
        control->gesture_start_ms = now_ms;
        control->gesture = 1u;
    }
    if (control->gesture == 2u) return;
    if ((uint32_t)(now_ms - control->gesture_start_ms) >=
        RC_BENCH_WAIT_MS + RC_BENCH_RUN_MS) {
        control->gesture = 2u;
        return;
    }
    if ((uint32_t)(now_ms - control->gesture_start_ms) >= RC_BENCH_WAIT_MS) {
        control->armed = 1u;
        control->command.throttle = (float)(RC_BENCH_BASE_US - RC_MOTOR_MIN_US) /
                                    (float)(RC_MOTOR_MAX_US - RC_MOTOR_MIN_US);
        control->setpoint.throttle = control->command.throttle;
    }
#endif
}
