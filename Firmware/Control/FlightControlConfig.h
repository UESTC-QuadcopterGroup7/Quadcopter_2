#ifndef FLIGHT_CONTROL_CONFIG_H
#define FLIGHT_CONTROL_CONFIG_H

/* 初始调试参数，尚未针对实机整定。所有角度为 deg，角速度为 deg/s，输出为 us。 */
#define FC_CONTROL_PERIOD_MS          5u
#define FC_FEEDBACK_TIMEOUT_MS        30u
#define FC_DT_MIN_S                   0.001f
#define FC_DT_MAX_S                   0.025f
/* 总倾角为机体向上轴与大地向上轴的夹角；0 度水平，180 度倒扣。 */
#define FC_ARM_MAX_TILT_DEG           15.0f
#define FC_STOP_MAX_TILT_DEG          70.0f
#define FC_TIPOVER_CLEAR_HOLD_MS       1000u /* 扶正、零油门、偏航左满持续确认。 */

/* 横滚/俯仰角度外环 P：输出目标欧拉角速度，单位 (deg/s)/deg。 */
#define FC_ROLL_ANGLE_KP              4.0f
#define FC_PITCH_ANGLE_KP             4.0f
#define FC_MAX_RP_RATE_DPS            120.0f

/* 三轴角速度内环：Kp [us/(deg/s)]，Ki [us/deg]，Kd [us/(deg/s^2)]。 */
#define FC_ROLL_RATE_KP               1.50f
#define FC_ROLL_RATE_KI               0.25f
#define FC_ROLL_RATE_KD               0.005f
#define FC_PITCH_RATE_KP              1.50f
#define FC_PITCH_RATE_KI              0.25f
#define FC_PITCH_RATE_KD              0.005f
#define FC_YAW_RATE_KP                1.00f
#define FC_YAW_RATE_KI                0.20f
#define FC_YAW_RATE_KD                0.00f
#define FC_RP_INTEGRAL_LIMIT_US       50.0f
#define FC_YAW_INTEGRAL_LIMIT_US      40.0f
#define FC_RP_OUTPUT_LIMIT_US         300.0f
#define FC_YAW_OUTPUT_LIMIT_US        120.0f

#define FC_GYRO_CUTOFF_HZ             30.0f
#define FC_DERIVATIVE_CUTOFF_HZ       10.0f
#define FC_INTEGRAL_MIN_THROTTLE      0.10f
#define FC_MIXER_TRACKING_GAIN        5.0f /* 混控后积分回算增益，单位 1/s。 */

#endif
