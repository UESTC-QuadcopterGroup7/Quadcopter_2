/* gcc -std=c99 -Wall -Wextra -Werror -pedantic -IMyLib
 *   Tests/test_rc_control.c MyLib/RC_Control.c -lm -o Objects/test_rc_control.exe
 */
#include "RC_Control.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static RC_Input_t Frame(uint32_t now)
{
    RC_Input_t input;
    unsigned i;
    memset(&input, 0, sizeof(input));
    input.valid_mask = RC_ALL_CHANNELS_MASK;
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        input.pulse_us[i] = RC_PWM_MID_US;
        input.updated_ms[i] = now;
    }
    return input;
}

static void Refresh(RC_Input_t *input, uint32_t now)
{
    unsigned i;
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) input->updated_ms[i] = now;
}

static void Close(float actual, float expected)
{
    assert(fabsf(actual - expected) < 1.0e-5f);
}

static uint16_t ThrottlePulse(uint16_t pulse)
{
    return RC_THROTTLE_DIRECTION == 1 ? pulse : (uint16_t)(3000u - pulse);
}

static uint16_t YawPulse(int right)
{
    return ((right ? 1 : -1) * RC_YAW_DIRECTION > 0) ? RC_PWM_MAX_US : RC_PWM_MIN_US;
}

static void AllStopped(const uint16_t motor[RC_MOTOR_COUNT])
{
    unsigned i;
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) assert(motor[i] == RC_MOTOR_OFF_US);
}

static void TestDecode(void)
{
    RC_Input_t input = Frame(100u);
    RC_Command_t command;
    RC_Setpoint_t setpoint;
    unsigned i;
    uint16_t pulse;
    assert(RC_Decode(&input, 100u, &command));
    Close(command.throttle, 0.0f);
    Close(command.roll, 0.0f);
    Close(command.pitch, 0.0f);
    Close(command.yaw, 0.0f);
    for (pulse = 1480u; pulse <= 1520u; ++pulse) {
        for (i = 0u; i < RC_CHANNEL_COUNT; ++i) input.pulse_us[i] = pulse;
        assert(RC_Decode(&input, 100u, &command));
        Close(command.roll, 0.0f);
        Close(command.pitch, 0.0f);
        Close(command.yaw, 0.0f);
        Close(command.throttle, 0.0f);
    }
    input = Frame(100u);
    input.pulse_us[RC_ROLL_CHANNEL] = 2000u;
    input.pulse_us[RC_PITCH_CHANNEL] = 2000u;
    input.pulse_us[RC_YAW_CHANNEL] = 2000u;
    input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(1760u);
    assert(RC_Decode(&input, 100u, &command));
    Close(command.roll, (float)RC_ROLL_DIRECTION);
    Close(command.pitch, (float)RC_PITCH_DIRECTION);
    Close(command.yaw, (float)RC_YAW_DIRECTION);
    Close(command.throttle, 0.5f);
    RC_MakeSetpoint(&command, &setpoint);
    Close(setpoint.roll_deg, 20.0f * (float)RC_ROLL_DIRECTION);
    Close(setpoint.pitch_deg, 20.0f * (float)RC_PITCH_DIRECTION);
    Close(setpoint.yaw_rate_dps, 90.0f * (float)RC_YAW_DIRECTION);
    input.pulse_us[RC_ROLL_CHANNEL] = 1000u;
    input.pulse_us[RC_PITCH_CHANNEL] = 1000u;
    input.pulse_us[RC_YAW_CHANNEL] = 1000u;
    input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(2000u);
    assert(RC_Decode(&input, 100u, &command));
    Close(command.roll, -(float)RC_ROLL_DIRECTION);
    Close(command.pitch, -(float)RC_PITCH_DIRECTION);
    Close(command.yaw, -(float)RC_YAW_DIRECTION);
    Close(command.throttle, 1.0f);
    for (pulse = 1000u; pulse <= 1520u; ++pulse) {
        input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(pulse);
        assert(RC_Decode(&input, 100u, &command));
        Close(command.throttle, 0.0f); /* 自动回中油门的整个下半程都必须停止。 */
    }
    input.pulse_us[RC_ROLL_CHANNEL] = 2100u;
    assert(RC_Decode(&input, 199u, &command));
    Close(command.roll, (float)RC_ROLL_DIRECTION);
    assert(!RC_Decode(&input, 200u, &command));

    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        input = Frame(100u);
        input.valid_mask &= (uint8_t)~(1u << i);
        assert(!RC_Decode(&input, 100u, &command));
        input = Frame(100u);
        input.pulse_us[i] = 899u;
        assert(!RC_Decode(&input, 100u, &command));
        input.pulse_us[i] = 2101u;
        assert(!RC_Decode(&input, 100u, &command));
        input = Frame(100u);
        input.updated_ms[i] = 0u;
        assert(!RC_Decode(&input, 100u, &command));
        Close(command.throttle, 0.0f);
        Close(command.yaw, 0.0f);
    }
    input = Frame(UINT32_MAX - 30u);
    assert(RC_Decode(&input, 20u, &command));
    assert(!RC_Decode(&input, 69u, &command));
    assert(!RC_Decode(NULL, 0u, &command));
    assert(!RC_Decode(&input, 0u, NULL));
}

static void TestMotorDirections(void)
{
    uint16_t motor[RC_MOTOR_COUNT];
    int direction;
    unsigned i;
    RC_Mix(1500.0f, 0.0f, 0.0f, 0.0f, motor);
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) assert(motor[i] == 1500u);
    for (direction = -1; direction <= 1; direction += 2) {
        RC_Mix(1500.0f, 100.0f * direction, 0.0f, 0.0f, motor);
        assert(motor[RC_MOTOR_FRONT_LEFT] == 1500 + 100 * direction);
        assert(motor[RC_MOTOR_REAR_LEFT] == 1500 + 100 * direction);
        assert(motor[RC_MOTOR_FRONT_RIGHT] == 1500 - 100 * direction);
        assert(motor[RC_MOTOR_REAR_RIGHT] == 1500 - 100 * direction);
        RC_Mix(1500.0f, 0.0f, 100.0f * direction, 0.0f, motor);
        assert(motor[RC_MOTOR_FRONT_LEFT] == 1500 + 100 * direction);
        assert(motor[RC_MOTOR_FRONT_RIGHT] == 1500 + 100 * direction);
        assert(motor[RC_MOTOR_REAR_LEFT] == 1500 - 100 * direction);
        assert(motor[RC_MOTOR_REAR_RIGHT] == 1500 - 100 * direction);
        RC_Mix(1500.0f, 0.0f, 0.0f, 100.0f * direction, motor);
        /* 顺时针机体转矩来自增大 CCW 电机，减小 CW 电机。 */
        assert(motor[RC_MOTOR_FRONT_LEFT] == 1500 + (RC_FRONT_LEFT_CW ? -100 : 100) * direction);
        assert(motor[RC_MOTOR_REAR_RIGHT] == motor[RC_MOTOR_FRONT_LEFT]);
        assert(motor[RC_MOTOR_FRONT_RIGHT] == 3000u - motor[RC_MOTOR_FRONT_LEFT]);
        assert(motor[RC_MOTOR_REAR_LEFT] == motor[RC_MOTOR_FRONT_RIGHT]);
    }
    RC_Mix(1950.0f, 100.0f, 0.0f, 0.0f, motor);
    assert(motor[RC_MOTOR_FRONT_LEFT] == 2000u && motor[RC_MOTOR_FRONT_RIGHT] == 1800u);
    RC_Mix(1001.0f, 100.0f, 0.0f, 0.0f, motor);
    assert(motor[RC_MOTOR_FRONT_LEFT] == 1200u && motor[RC_MOTOR_FRONT_RIGHT] == 1000u);
    RC_Mix(1500.0f, 1000.0f, 1000.0f, 0.0f, motor);
    assert(motor[RC_MOTOR_FRONT_LEFT] == 2000u && motor[RC_MOTOR_REAR_RIGHT] == 1000u);
    assert(motor[RC_MOTOR_FRONT_RIGHT] == 1500u && motor[RC_MOTOR_REAR_LEFT] == 1500u);
}

static void TestSaturation(void)
{
    const float bases[] = {1001.0f, 1050.0f, 1500.0f, 1950.0f, 2000.0f};
    const float axes[] = {-1000.0f, -100.0f, 0.0f, 100.0f, 1000.0f};
    uint16_t m[RC_MOTOR_COUNT];
    unsigned t, r, p, y, i;
    for (t = 0u; t < 5u; ++t) for (r = 0u; r < 5u; ++r)
    for (p = 0u; p < 5u; ++p) for (y = 0u; y < 5u; ++y) {
        int roll_torque, pitch_torque, yaw_torque;
        RC_Mix(bases[t], axes[r], axes[p], axes[y], m);
        for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
            assert(m[i] >= 1000u && m[i] <= 2000u);
        }
        roll_torque = (int)m[RC_MOTOR_FRONT_LEFT] + m[RC_MOTOR_REAR_LEFT] -
                     m[RC_MOTOR_FRONT_RIGHT] - m[RC_MOTOR_REAR_RIGHT];
        pitch_torque = (int)m[RC_MOTOR_FRONT_LEFT] + m[RC_MOTOR_FRONT_RIGHT] -
                      m[RC_MOTOR_REAR_LEFT] - m[RC_MOTOR_REAR_RIGHT];
        yaw_torque = ((int)m[RC_MOTOR_FRONT_RIGHT] + m[RC_MOTOR_REAR_LEFT] -
                      m[RC_MOTOR_FRONT_LEFT] - m[RC_MOTOR_REAR_RIGHT]) *
                     (RC_FRONT_LEFT_CW ? 1 : -1);
        assert(axes[r] == 0.0f ? abs(roll_torque) <= 1 : roll_torque * axes[r] > 0.0f);
        assert(axes[p] == 0.0f ? abs(pitch_torque) <= 1 : pitch_torque * axes[p] > 0.0f);
        assert(axes[y] == 0.0f ? abs(yaw_torque) <= 1 : yaw_torque * axes[y] > 0.0f);
    }
    RC_Mix(1000.0f, 100.0f, 100.0f, 100.0f, m);
    AllStopped(m);
    RC_Mix(NAN, 0.0f, 0.0f, 0.0f, m);
    AllStopped(m);
    RC_Mix(1500.0f, INFINITY, 0.0f, 0.0f, m);
    AllStopped(m);
    RC_Mix(1500.0f, 0.0f, NAN, 0.0f, m);
    AllStopped(m);
    RC_Mix(1500.0f, 0.0f, 0.0f, -INFINITY, m);
    AllStopped(m);
}

static void Hold(RC_Control_t *control, RC_Input_t *input, uint32_t start, uint32_t duration)
{
    uint32_t elapsed;
    for (elapsed = 0u; elapsed <= duration; elapsed += 20u) {
        Refresh(input, start + elapsed);
        RC_Control_Update(control, input, start + elapsed);
    }
}

static void TestControlState(void)
{
    RC_Control_t control;
    RC_Input_t input = Frame(0u);
    unsigned i;
    RC_Control_Init(&control);
    AllStopped(control.motor_us);
    input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(2000u);
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(1);
    Hold(&control, &input, 0u, 1200u);
    assert(!control.armed);
    AllStopped(control.motor_us);

    input = Frame(1300u);
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(1);
    Hold(&control, &input, 1300u, RC_ARM_HOLD_MS - 20u);
    assert(!control.armed);
    input.pulse_us[RC_YAW_CHANNEL] = RC_PWM_MID_US; /* 打断手势必须重新计时。 */
    Hold(&control, &input, 2300u, 0u);
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(1);
    Hold(&control, &input, 2320u, 980u);
    assert(!control.armed);
    Hold(&control, &input, 3320u, 0u);
    assert(control.armed && control.signal_valid);
    AllStopped(control.motor_us);

    input = Frame(3340u);
    input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(1760u);
    Hold(&control, &input, 3340u, 0u);
    for (i = 0u; i < RC_MOTOR_COUNT; ++i) assert(control.motor_us[i] == 1500u);
    input.pulse_us[RC_THROTTLE_CHANNEL] = RC_PWM_MID_US;
    input.pulse_us[RC_ROLL_CHANNEL] = RC_PWM_MAX_US;
    Hold(&control, &input, 3360u, 0u);
    AllStopped(control.motor_us); /* 松油门即停，其他摇杆不应覆盖停止。 */

    input = Frame(3380u);
    input.pulse_us[RC_THROTTLE_CHANNEL] = ThrottlePulse(1760u);
    Hold(&control, &input, 3380u, 0u);
    Refresh(&input, 3480u);
    input.updated_ms[RC_ROLL_CHANNEL] = 3380u;
    RC_Control_Update(&control, &input, 3480u); /* 仅一路掉线也必须停。 */
    assert(!control.armed && !control.signal_valid);
    AllStopped(control.motor_us);
    Hold(&control, &input, 3500u, 1200u);
    assert(!control.armed); /* 信号恢复且高油门不能自动重启。 */
    AllStopped(control.motor_us);

    input = Frame(UINT32_MAX - 500u);
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(1);
    Hold(&control, &input, UINT32_MAX - 500u, RC_ARM_HOLD_MS);
    assert(control.armed);
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(0);
    Hold(&control, &input, 600u, RC_ARM_HOLD_MS);
    assert(!control.armed);
    AllStopped(control.motor_us);

    input = Frame(1620u);
    input.pulse_us[RC_ROLL_CHANNEL] = RC_PWM_MAX_US;
    input.pulse_us[RC_YAW_CHANNEL] = YawPulse(1);
    Hold(&control, &input, 1620u, 1200u);
    assert(!control.armed);
    RC_Control_Update(&control, NULL, 2840u);
    assert(!control.armed && !control.signal_valid);
    AllStopped(control.motor_us);
}

int main(void)
{
    TestDecode();
    TestMotorDirections();
    TestSaturation();
    TestControlState();
    puts("PASS: centered throttle, endpoints/deadband, setpoints, four motor directions,");
    puts("      625 saturation cases, arming/disarming, per-channel failsafe and tick wrap.");
    return 0;
}
