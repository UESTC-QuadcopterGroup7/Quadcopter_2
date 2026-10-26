#ifndef __ATTITUDE_H
#define __ATTITUDE_H

#include <stdint.h>
#include "Quaternion.h"

/*
 * 姿态解算：Madgwick 梯度下降滤波（四元数表示）
 *
 * 一、原理
 *    陀螺仪积分给出短时间内的姿态，加速度计和磁力计提供不含累积误差的方向观测。
 *    Madgwick 把"由当前姿态推算的方向"与"实测方向"之差写成一个目标函数：
 *
 *        f(q) = [ v(q) - â ;  w(q) - m̂ ]
 *
 *        v(q) = R(q)ᵀ·(0,0,1)     当前姿态下加速度计应测到的重力方向
 *        w(q) = R(q)ᵀ·(bx,0,bz)   当前姿态下磁力计应测到的磁场方向
 *
 *    对其求梯度 ∇f = Jᵀ·f（J 是 f 对四元数的雅可比矩阵），再沿负梯度方向修正：
 *
 *        q̇ = ½·q ⊗ ω − β · ∇f / |∇f|
 *        q ← q + q̇·dt ，随后归一化
 *
 *    β 是唯一需要调的增益：越大收敛越快，也越容易把振动和线性加速度当成倾角误差。
 *    只有加速度计时是六轴融合（f 取前 3 行），同时给磁场时是九轴融合（f 取 6 行），
 *    此时 b = (|h_xy|, 0, h_z)，h 为观测磁场转到大地系后的方向，即假定大地系 X 轴为磁北。
 *
 * 二、与 Mahony 互补滤波的区别
 *    - 没有积分项，因此不估计陀螺零偏：零偏仍靠 MPU6050 的上电静止校准消除，
 *      残余零偏会表现为一个固定的小倾角偏差，而不是缓慢漂移；
 *    - 修正量来自目标函数的梯度，九轴时倾角与航向由同一个准则一起求解；
 *    - 参数只有一个 β，没有 Kp / Ki 的相互牵扯。
 *
 * 三、输入输出
 *    输入：机体系角速度 (rad/s)、机体系加速度 (g)、机体系磁场 (任意单位，只取方向)、dt (s)。
 *    输出：机体 → 大地的单位四元数，以及 ZYX 欧拉角。
 *    坐标系与欧拉角定义见 Quaternion.h；加速度在静止时应为 (0, 0, +1) g。
 *
 * 四、使用步骤
 *        Attitude_t att;
 *        Attitude_InitRaw(&att, accel_raw, mag_raw);                 // 用一个静止样本对准水平与航向
 *        ...
 *        Attitude_UpdateRaw(&att, accel_raw, gyro_raw, mag_raw, dt); // 周期调用
 *
 *    mag_raw 传 NULL 即退化为六轴（无航向观测，yaw 只能靠陀螺积分）。
 *    原始计数的量程换算在 Attitude.c 内完成，与 GY86.h 中的配置保持一致。
 */

/* Attitude_Update() / Attitude_UpdateRaw() 的返回值 */
#define ATTITUDE_FLAG_UPDATED   0x01u   /* 本次调用完成了一次姿态更新 */
#define ATTITUDE_FLAG_ACCEL     0x02u   /* 本次使用了加速度计（重力方向）修正 */
#define ATTITUDE_FLAG_MAG       0x04u   /* 本次使用了磁力计（航向）修正 */

/*
 * β 增益 (rad/s)：陀螺仪姿态与观测方向之间残差的收敛速率。
 * Madgwick 原文的取值方法为 β = √(3/4)·ω_β，ω_β 是陀螺仪的测量误差 (rad/s)。
 * 按上电校准后残余 5°/s (0.087 rad/s) 估算，β ≈ 0.075；这里默认 0.1。
 * β 为 0 时退化为纯陀螺积分。
 */
#ifndef ATTITUDE_BETA_DEFAULT
#define ATTITUDE_BETA_DEFAULT   0.10f
#endif

/* 单次更新的时间步长上限/下限，防止任务被长时间抢占后一步积分过大 */
#ifndef ATTITUDE_DT_MAX
#define ATTITUDE_DT_MAX         0.050f
#endif
#ifndef ATTITUDE_DT_MIN
#define ATTITUDE_DT_MIN         0.0005f
#endif

/* 只在该加速度模长区间内采信加速度计（单位 g）：自由落体和剧烈冲击会被拒绝 */
#ifndef ATTITUDE_ACCEL_MIN_G
#define ATTITUDE_ACCEL_MIN_G    0.30f
#endif
#ifndef ATTITUDE_ACCEL_MAX_G
#define ATTITUDE_ACCEL_MAX_G    3.00f
#endif

/*
 * 磁场水平分量（归一化后）小于该值时不再用它修正航向：
 * 磁场几乎竖直时航向没有可观测性，强行融合只会把噪声引进倾角。
 */
#ifndef ATTITUDE_MAG_MIN_HORIZONTAL
#define ATTITUDE_MAG_MIN_HORIZONTAL  0.01f
#endif

typedef struct {
    Quaternion_t  q;            /* 机体 → 大地 */
    EulerAngles_t euler;        /* 由 q 换算的欧拉角 (rad) */
    float         beta;         /* 梯度下降增益 (rad/s) */
    uint8_t       accel_valid;  /* 最近一次更新是否使用了加速度计 */
    uint8_t       mag_valid;    /* 最近一次更新是否使用了磁力计 */
} Attitude_t;

/* 复位为单位姿态并恢复默认 β。 */
void Attitude_Reset(Attitude_t *att);

/* 修改梯度下降增益 β；β <= 0 表示关闭观测修正，只做陀螺积分。 */
void Attitude_SetBeta(Attitude_t *att, float beta);

/*
 * 用静止样本初始化姿态：
 *   - 由加速度计求横滚、俯仰（要求模长在 ATTITUDE_ACCEL_MIN_G..MAX_G 之间）；
 *   - 有磁力计时用倾斜补偿求出偏航，没有则偏航置 0。
 * 成功返回 1；加速度不可信时返回 0，此时姿态为单位值，可稍后重试。
 */
uint8_t Attitude_Init(Attitude_t *att, const Vector3f_t *accel, const Vector3f_t *mag);

/* 同上，输入为补偿后的 MPU6050 / HMC5883L 原始计数；mag 可为 NULL。 */
uint8_t Attitude_InitRaw(Attitude_t *att, const int16_t accel[3], const int16_t mag[3]);

/*
 * 姿态更新。
 *   gyro  : 机体角速度 (rad/s)
 *   accel : 机体加速度 (g)，静止时为重力反作用力方向
 *   mag   : 机体磁场 (任意单位)，可为 NULL
 *   dt    : 距上次更新的时间 (s)，会被限幅到 ATTITUDE_DT_MIN..MAX
 * 返回 ATTITUDE_FLAG_* 的组合；参数非法或 dt 非正时返回 0 且不改变姿态。
 */
uint8_t Attitude_Update(Attitude_t *att, const Vector3f_t *gyro, const Vector3f_t *accel,
                        const Vector3f_t *mag, float dt);

/* 同上，输入为 MPU6050 / HMC5883L 的原始计数；mag 可为 NULL。 */
uint8_t Attitude_UpdateRaw(Attitude_t *att, const int16_t accel[3], const int16_t gyro[3],
                           const int16_t mag[3], float dt);

/* 读取欧拉角 (rad)。 */
void Attitude_GetEuler(const Attitude_t *att, EulerAngles_t *euler);

/* 读取欧拉角 (°)。 */
void Attitude_GetEulerDegrees(const Attitude_t *att, float *roll_deg, float *pitch_deg, float *yaw_deg);

#endif
