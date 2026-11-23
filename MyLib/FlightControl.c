#include "FlightControl.h"
#include "GY86.h"
#include <float.h>
#include <math.h>
#include <string.h>

#define FC_DEG_TO_RAD 0.01745329251994329577f
#define FC_RAD_TO_DEG 57.29577951308232087680f

static uint8_t Finite(float value)
{
    return (uint8_t)(value >= -FLT_MAX && value <= FLT_MAX);
}

static float Limit(float value, float magnitude)
{
    if (value > magnitude) return magnitude;
    if (value < -magnitude) return -magnitude;
    return value;
}

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

static void ResetLoops(FC_Control_t *control)
{
    uint8_t i;
    for (i = 0u; i < FC_AXIS_COUNT; ++i) {
        PID_Reset(&control->rate_pid[i]);
        control->rate_setpoint_dps[i] = 0.0f;
        control->filtered_rate_dps[i] = 0.0f;
        control->correction_us[i] = 0.0f;
    }
    control->running = 0u;
    control->dt_s = 0.0f;
}

static void Fault(FC_Control_t *control, FC_Status_t status)
{
    RC_Control_Disarm(&control->rc);
    ResetLoops(control);
    control->tipover_clear_pending = 0u;
    control->status = status;
}

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

static void HoldTipoverFault(FC_Control_t *control, float upward_cosine, uint32_t now_ms)
{
    const RC_Command_t *command = &control->rc.command;
    RC_Control_Disarm(&control->rc);
    ResetLoops(control);
    control->status = FC_STATUS_EXCESS_TILT;

    /* 明确的解除手势，不能仅因机体摆正或遥控信号恢复就重新启动电机。 */
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

void FC_Control_Update(FC_Control_t *control, const RC_Input_t *input,
                       const FC_Feedback_t *feedback, uint32_t now_ms)
{
    uint8_t i, new_sample, allow_integral, was_armed;
    float upward_cosine;
    if (control == 0) return;
    was_armed = control->rc.armed;
    RC_Control_Update(&control->rc, input, now_ms);
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
