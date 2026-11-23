#include "RC_Control.h"
#include <float.h>
#include <string.h>

#define RC_GESTURE_NONE     0u
#define RC_GESTURE_ARM      1u
#define RC_GESTURE_DISARM   2u

static float Clamp(float value, float low, float high)
{
    if (value < low) return low;
    if (value > high) return high;
    return value;
}

static uint8_t Finite(float value)
{
    return (uint8_t)(value >= -FLT_MAX && value <= FLT_MAX);
}

static void StopMotors(uint16_t motor_us[RC_MOTOR_COUNT])
{
    uint8_t i;
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
        motor_us[i] = RC_MOTOR_OFF_US;
    }
}

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

void RC_MakeSetpoint(const RC_Command_t *command, RC_Setpoint_t *setpoint)
{
    if (setpoint == 0) return;
    memset(setpoint, 0, sizeof(*setpoint));
    if (command == 0) return;
    setpoint->throttle = command->throttle;
    setpoint->roll_deg = command->roll * RC_MAX_ROLL_DEG;
    setpoint->pitch_deg = command->pitch * RC_MAX_PITCH_DEG;
    setpoint->yaw_rate_dps = command->yaw * RC_MAX_YAW_RATE_DPS;
}

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

void RC_Control_Init(RC_Control_t *control)
{
    if (control == 0) return;
    memset(control, 0, sizeof(*control));
    StopMotors(control->motor_us);
}

void RC_Control_Update(RC_Control_t *control, const RC_Input_t *input, uint32_t now_ms)
{
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

    /* 回中油门始终输出停止值，摇动其余三路也不会带动电机。 */
    if (control->armed == 0u || control->command.throttle <= 0.0f) return;
    RC_Mix((float)RC_MOTOR_MIN_US + control->command.throttle *
           (float)(RC_MOTOR_MAX_US - RC_MOTOR_MIN_US),
           control->command.roll * RC_ROLL_MIX_US,
           control->command.pitch * RC_PITCH_MIX_US,
           control->command.yaw * RC_YAW_MIX_US, control->motor_us);
}
