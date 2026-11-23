#include "PID.h"
#include <float.h>
#include <string.h>

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

static uint8_t ConfigValid(const PID_Config_t *c)
{
    return (uint8_t)(c != 0 && Finite(c->kp) && c->kp >= 0.0f &&
           Finite(c->ki) && c->ki >= 0.0f && Finite(c->kd) && c->kd >= 0.0f &&
           Finite(c->integral_limit) && c->integral_limit >= 0.0f &&
           Finite(c->output_limit) && c->output_limit > 0.0f &&
           Finite(c->derivative_cutoff_hz) && c->derivative_cutoff_hz >= 0.0f);
}

void PID_Reset(PID_t *pid)
{
    PID_Config_t config;
    uint8_t configured;
    if (pid == 0) return;
    config = pid->config;
    configured = pid->configured;
    memset(pid, 0, sizeof(*pid));
    pid->config = config;
    pid->configured = configured;
}

uint8_t PID_Init(PID_t *pid, const PID_Config_t *config)
{
    PID_Config_t copy;
    if (pid == 0) return 0u;
    if (!ConfigValid(config)) {
        memset(pid, 0, sizeof(*pid));
        return 0u;
    }
    copy = *config;
    memset(pid, 0, sizeof(*pid));
    pid->config = copy;
    pid->configured = 1u;
    return 1u;
}

uint8_t PID_Update(PID_t *pid, float setpoint, float measurement, float dt,
                   uint8_t allow_integral)
{
    float error, derivative = 0.0f, candidate_i, sum, delta_i;
    if (pid == 0) return 0u;
    if (pid->configured == 0u || !ConfigValid(&pid->config) ||
        !Finite(setpoint) || !Finite(measurement) || !Finite(dt) || dt <= 0.0f || dt > 1.0f) {
        PID_Reset(pid);
        return 0u;
    }
    error = setpoint - measurement;
    if (pid->initialized != 0u) {
        float alpha = 1.0f;
        derivative = (measurement - pid->previous_measurement) / dt;
        if (pid->config.derivative_cutoff_hz > 0.0f) {
            float tau = 1.0f / (6.28318530718f * pid->config.derivative_cutoff_hz);
            alpha = dt / (tau + dt);
        }
        derivative = pid->derivative + alpha * (derivative - pid->derivative);
    }
    pid->p_term = pid->config.kp * error;
    pid->d_term = -pid->config.kd * derivative;
    candidate_i = pid->i_term;
    if (allow_integral != 0u) {
        candidate_i = Limit(candidate_i + pid->config.ki * error * dt,
                            pid->config.integral_limit);
    }
    sum = pid->p_term + candidate_i + pid->d_term;
    delta_i = candidate_i - pid->i_term;
    if ((sum > pid->config.output_limit && delta_i > 0.0f) ||
        (sum < -pid->config.output_limit && delta_i < 0.0f)) {
        candidate_i = pid->i_term; /* 只拒绝使饱和更严重的积分，允许反向退饱和。 */
    }
    sum = pid->p_term + candidate_i + pid->d_term;
    if (!Finite(error) || !Finite(derivative) || !Finite(sum)) {
        PID_Reset(pid);
        return 0u;
    }
    pid->error = error;
    pid->i_term = candidate_i;
    pid->output = Limit(sum, pid->config.output_limit);
    pid->derivative = derivative;
    pid->previous_measurement = measurement;
    pid->initialized = 1u;
    return 1u;
}

void PID_TrackOutput(PID_t *pid, float applied_output, float tracking_gain, float dt)
{
    float difference, integral;
    if (pid == 0 || pid->configured == 0u || pid->config.ki <= 0.0f ||
        !Finite(applied_output) || !Finite(tracking_gain) || tracking_gain <= 0.0f ||
        !Finite(dt) || dt <= 0.0f || dt > 1.0f) return;
    difference = applied_output - pid->output;
    if (difference >= -0.5f && difference <= 0.5f) return; /* 忽略 PWM 取整误差。 */
    integral = pid->i_term + Limit(tracking_gain * dt, 1.0f) * difference;
    if (Finite(integral)) pid->i_term = Limit(integral, pid->config.integral_limit);
}
