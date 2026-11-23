#ifndef RC_CONFIG_H
#define RC_CONFIG_H

/* 接收机数组下标：0=CH1，1=CH2，2=CH3，3=CH4。 */
#ifndef RC_ROLL_CHANNEL
#define RC_ROLL_CHANNEL       0u
#endif
#ifndef RC_PITCH_CHANNEL
#define RC_PITCH_CHANNEL      1u
#endif
#ifndef RC_THROTTLE_CHANNEL
#define RC_THROTTLE_CHANNEL   2u
#endif
#ifndef RC_YAW_CHANNEL
#define RC_YAW_CHANNEL        3u
#endif

/* +1：脉宽增大为正；-1：反向。抬头为正，因此前推增大脉宽时俯仰取 -1。 */
#ifndef RC_ROLL_DIRECTION
#define RC_ROLL_DIRECTION      1
#endif
#ifndef RC_PITCH_DIRECTION
#define RC_PITCH_DIRECTION    (-1)
#endif
#ifndef RC_THROTTLE_DIRECTION
#define RC_THROTTLE_DIRECTION  1
#endif
#ifndef RC_YAW_DIRECTION
#define RC_YAW_DIRECTION       1
#endif

/* 俯视：已确认左前 CW；右后也须 CW，右前/左后须 CCW。 */
#ifndef RC_FRONT_LEFT_CW
#define RC_FRONT_LEFT_CW       1
#endif

#define RC_CHANNEL_COUNT      4u
#define RC_ALL_CHANNELS_MASK   0x0Fu
#define RC_PWM_MIN_US          1000u
#define RC_PWM_MID_US          1500u
#define RC_PWM_MAX_US          2000u
#define RC_VALID_MIN_US        900u
#define RC_VALID_MAX_US        2100u
#define RC_DEADBAND_US         20u
#define RC_SIGNAL_TIMEOUT_MS   100u
#define RC_ARM_HOLD_MS         1000u

/* 自动回中油门：1000..1520 停机，1520..2000 线性映射为 0..1。
 * RC_THROTTLE_DIRECTION=-1 时先反向，再采用同一规则。 */
#define RC_THROTTLE_START_US   (RC_PWM_MID_US + RC_DEADBAND_US)

#define RC_MOTOR_MIN_US        1000u
#define RC_MOTOR_MAX_US        2000u
#define RC_MOTOR_OFF_US        RC_MOTOR_MIN_US

/* 姿态/角速度闭环的目标值；PID 参数见 FlightControlConfig.h。 */
#define RC_MAX_ROLL_DEG        20.0f
#define RC_MAX_PITCH_DEG       20.0f
#define RC_MAX_YAW_RATE_DPS    90.0f

#if RC_ROLL_CHANNEL >= RC_CHANNEL_COUNT || RC_PITCH_CHANNEL >= RC_CHANNEL_COUNT || \
    RC_THROTTLE_CHANNEL >= RC_CHANNEL_COUNT || RC_YAW_CHANNEL >= RC_CHANNEL_COUNT
#error RC channel index must be in 0..3
#endif
#if RC_ROLL_CHANNEL == RC_PITCH_CHANNEL || RC_ROLL_CHANNEL == RC_THROTTLE_CHANNEL || \
    RC_ROLL_CHANNEL == RC_YAW_CHANNEL || RC_PITCH_CHANNEL == RC_THROTTLE_CHANNEL || \
    RC_PITCH_CHANNEL == RC_YAW_CHANNEL || RC_THROTTLE_CHANNEL == RC_YAW_CHANNEL
#error RC channel assignments must be distinct
#endif
#if (RC_ROLL_DIRECTION != 1 && RC_ROLL_DIRECTION != -1) || \
    (RC_PITCH_DIRECTION != 1 && RC_PITCH_DIRECTION != -1) || \
    (RC_THROTTLE_DIRECTION != 1 && RC_THROTTLE_DIRECTION != -1) || \
    (RC_YAW_DIRECTION != 1 && RC_YAW_DIRECTION != -1)
#error RC channel direction must be 1 or -1
#endif
#if RC_FRONT_LEFT_CW != 0 && RC_FRONT_LEFT_CW != 1
#error RC_FRONT_LEFT_CW must be 0 or 1
#endif

#endif
