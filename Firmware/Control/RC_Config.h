/*
 * Radio Control Configuration
 * 定义四旋翼的遥控器和台架测试配置，包括接收机开关、通道映射、PWM 范围及调参时的姿态目标锁定。
 * 分为两种模式，遥控器模式和台架测试模式
 */

#ifndef RC_CONFIG_H
#define RC_CONFIG_H

/* 0：关闭接收机采集及遥控解码，启用下面的自动台架测试。
 * 注意：无需遥控器，上电等待后会自行启动电机；只用于固定测试架。
 * 1：恢复正常接收机控制、手势解锁和失联检测。
 * 
 * #define RC_RECEIVER_ENABLED    0之后进入调试模式，若要恢复正常遥控器控制，改为 1 并重新编译烧录。
 */
#ifndef RC_RECEIVER_ENABLED
#define RC_RECEIVER_ENABLED    0
#endif
#if RC_RECEIVER_ENABLED != 0 && RC_RECEIVER_ENABLED != 1
#error RC_RECEIVER_ENABLED must be 0 or 1
#endif

/* 无接收机台架测试参数 */
// 启动检查连续通过 10 秒后，电机自动启动。等待期间检查失败会重置计时。
#define RC_BENCH_WAIT_MS        10000u
// 从自动启动开始计时，运行满 30 秒后停机。
#define RC_BENCH_RUN_MS         30000u
// 电机混控的基础 PWM 脉宽，在 1000–2000 µs 的油门范围内对应 15% 的油门指令。PID 会按姿态误差调整各电机的脉宽。
#define RC_BENCH_BASE_US        1150u

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
// 遥控器油门通道的方向设置。1（默认）：接收机的 PWM 脉宽越大，油门指令越大
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

#if RC_BENCH_BASE_US <= RC_MOTOR_MIN_US || RC_BENCH_BASE_US > RC_MOTOR_MAX_US
#error RC_BENCH_BASE_US must be above minimum and at most maximum throttle
#endif

/* 姿态/角速度闭环的目标值；PID 参数见 FlightControlConfig.h。 */
/* 
 * 这三个宏用于 PID 调参时锁定飞控目标，横滚、俯仰和偏航可以分别设置。当前默认都是 1。
 * 宏	                设为 1 时的目标
 * RC_TUNING_LOCK_ROLL	横滚角 0°
 * RC_TUNING_LOCK_PITCH	俯仰角 0°
 * RC_TUNING_LOCK_YAW	偏航角速度 0°/s
 */
#ifndef RC_TUNING_LOCK_ROLL
#define RC_TUNING_LOCK_ROLL     1
#endif
#ifndef RC_TUNING_LOCK_PITCH
#define RC_TUNING_LOCK_PITCH    1
#endif
#ifndef RC_TUNING_LOCK_YAW
#define RC_TUNING_LOCK_YAW      1
#endif

// #if (RC_TUNING_LOCK_ROLL != 0 && RC_TUNING_LOCK_ROLL != 1) || \
//     (RC_TUNING_LOCK_PITCH != 0 && RC_TUNING_LOCK_PITCH != 1) || \
//     (RC_TUNING_LOCK_YAW != 0 && RC_TUNING_LOCK_YAW != 1)
// #error RC tuning locks must be 0 or 1
// #endif

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
