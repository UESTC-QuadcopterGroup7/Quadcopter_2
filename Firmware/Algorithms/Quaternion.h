#ifndef __QUATERNION_H
#define __QUATERNION_H

#include <stdint.h>

/*
 * 四元数与三维向量运算
 *
 * 本模块只做纯数学运算，不访问任何硬件，可以脱离目标板单独编译、测试。
 * 全部使用 IEEE-754 单精度浮点（STM32F401 的 Cortex-M4 带硬件 FPU）。
 *
 * 一、旋转约定
 *     q = (w, x, y, z) 为单位四元数，表示"机体坐标系 B → 大地坐标系 E"的旋转：
 *
 *         v_E = q ⊗ v_B ⊗ q*          (q* 为 q 的共轭)
 *
 *     乘法采用 Hamilton 积，旋转方向遵循右手定则。
 *
 * 二、坐标系
 *     机体坐标系 B：与 MPU6050 芯片轴一致，X 指向机头，Y 指向左翼，Z 指向上方，
 *                   三者构成右手系（元件面朝上平放时 Z 向上，与现有 Z 轴保留 1g
 *                   的加速度校准一致）。
 *     大地坐标系 E：X 指北，Y 指西，Z 指天，同样是右手系。
 *                   北-西-天是右手系；北-东-天是左手系，会让所有旋转方向反号，
 *                   因此不能把 Y 轴理解成"东"。
 *
 * 三、欧拉角
 *     采用 ZYX 顺序（先绕 Z 偏航，再绕 Y 俯仰，最后绕 X 横滚）：
 *
 *         R = Rz(-yaw) · Ry(-pitch) · Rx(roll)
 *
 *     注意 yaw 与 pitch 前面是负号。地理系 Z 轴向上时，若照搬航空上常用的
 *     NED（Z 轴向下）公式，会得到"低头为正、左转为正"的反直觉结果；这里把
 *     这两个角取负，使它们与飞行器的习惯一致：
 *
 *     roll  横滚角，右滚（右翼下沉、左翼抬起）为正；
 *     pitch 俯仰角，抬头为正；
 *     yaw   偏航角，右转（俯视顺时针）为正，即罗盘航向，北为 0、东为 +90°。
 *
 *     角度一律用弧度，需要角度值时用 QUATERNION_RAD_TO_DEG 换算。
 *     pitch = ±90° 时 roll 与 yaw 会退化为同一自由度（万向节死锁）。
 *
 * 四、单位
 *     角度 rad，角速度 rad/s，时间 s，向量长度任意（归一化后只剩方向）。
 */

typedef struct {
    float w, x, y, z;
} Quaternion_t;

typedef struct {
    float x, y, z;
} Vector3f_t;

/*
 * 欧拉角（弧度）。
 * roll ∈ [-π, π]，pitch ∈ [-π/2, π/2]，yaw ∈ [-π, π]。
 * pitch = ±90° 时 roll 与 yaw 会退化为同一自由度（万向节死锁），
 * 这是欧拉角表示本身的缺陷，四元数本身没有该问题。
 */
typedef struct {
    float roll, pitch, yaw;
} EulerAngles_t;

#define QUATERNION_PI        3.14159265358979323846f
#define QUATERNION_HALF_PI   1.57079632679489661923f
#define QUATERNION_TWO_PI    6.28318530717958647693f
#define QUATERNION_DEG_TO_RAD 0.01745329251994329577f
#define QUATERNION_RAD_TO_DEG 57.29577951308232087680f

/* 判定零向量/零四元数的下限 */
#define QUATERNION_EPS       1.0e-6f

/* ================================================================
 *  构造
 * ================================================================ */

/* 单位四元数 (1, 0, 0, 0)，表示没有任何旋转。 */
void Quaternion_Identity(Quaternion_t *q);

/* 绕任意轴旋转 angle 弧度；axis 不必归一化，长度为 0 时得到单位四元数。 */
void Quaternion_FromAxisAngle(Quaternion_t *q, float axis_x, float axis_y, float axis_z, float angle);

/* 由 ZYX 欧拉角构造。与 Quaternion_ToEuler() 互逆。 */
void Quaternion_FromEuler(Quaternion_t *q, float roll, float pitch, float yaw);

/* 构造把 from 方向转到 to 方向的最短旋转。 */
void Quaternion_FromTwoVectors(Quaternion_t *q, const Vector3f_t *from, const Vector3f_t *to);

/* 由 3×3 旋转矩阵构造，m 为行主序：m[0..2] 是第一行。 */
void Quaternion_FromRotationMatrix(Quaternion_t *q, const float m[9]);

/* ================================================================
 *  转换
 * ================================================================ */

/* 转换为 ZYX 欧拉角（弧度）。 */
void Quaternion_ToEuler(const Quaternion_t *q, EulerAngles_t *euler);

/* 转换为 3×3 旋转矩阵（行主序，机体 → 大地，即 v_E = R · v_B）。 */
void Quaternion_ToRotationMatrix(const Quaternion_t *q, float m[9]);

/* ================================================================
 *  基本运算
 * ================================================================ */

/* out = a ⊗ b（Hamilton 积）。允许 out 与 a 或 b 指向同一对象。 */
void Quaternion_Multiply(Quaternion_t *out, const Quaternion_t *a, const Quaternion_t *b);

/* out = q*，共轭（对单位四元数等价于逆旋转）。 */
void Quaternion_Conjugate(Quaternion_t *out, const Quaternion_t *q);

/* out = q⁻¹，逆四元数；非单位四元数也成立。 */
void Quaternion_Inverse(Quaternion_t *out, const Quaternion_t *q);

/* 模长 |q|。 */
float Quaternion_Norm(const Quaternion_t *q);

/* 归一化为单位四元数；模长接近 0 或含 NaN 时返回 0 且不修改 q。 */
uint8_t Quaternion_Normalize(Quaternion_t *q);

/* 点积；两个单位四元数点积的绝对值可用于衡量姿态差异。 */
float Quaternion_Dot(const Quaternion_t *a, const Quaternion_t *b);

/* 两个姿态之间的最短夹角（弧度，∈[0, π]）。 */
float Quaternion_AngleBetween(const Quaternion_t *a, const Quaternion_t *b);

/* 球面线性插值，t ∈ [0,1]；t=0 得 a，t=1 得 b。 */
void Quaternion_Slerp(Quaternion_t *out, const Quaternion_t *a, const Quaternion_t *b, float t);

/* ================================================================
 *  向量旋转
 * ================================================================ */

/* v_E = q ⊗ v_B ⊗ q*，把机体系向量转到大地系。 */
void Quaternion_RotateVector(Vector3f_t *out, const Quaternion_t *q, const Vector3f_t *v);

/* v_B = q* ⊗ v_E ⊗ q，把大地系向量转到机体系。 */
void Quaternion_RotateVectorInverse(Vector3f_t *out, const Quaternion_t *q, const Vector3f_t *v);

/* ================================================================
 *  与角速度相关的积分
 * ================================================================ */

/*
 * 四元数导数：qdot = ½ · q ⊗ (0, ω)，ω 为机体角速度 (rad/s)。
 * 仅用于推导或外部积分器；常规姿态更新请用 Quaternion_IntegrateBodyRate()。
 */
void Quaternion_Derivative(Quaternion_t *qdot, const Quaternion_t *q, float wx, float wy, float wz);

/*
 * 用机体角速度推进 dt 秒：q ← q ⊗ exp(½·ω·dt)，随后归一化。
 * 该式对 dt 内的恒定角速度是精确解，因此大步长下也不会像一阶欧拉积分那样
 * 出现明显的模长漂移，适合"变化不定的采样周期"。
 */
void Quaternion_IntegrateBodyRate(Quaternion_t *q, float wx, float wy, float wz, float dt);

/* ================================================================
 *  三维向量工具
 * ================================================================ */

float Vector3f_Length(const Vector3f_t *v);
float Vector3f_Dot(const Vector3f_t *a, const Vector3f_t *b);

/* out = a × b。允许 out 与 a 或 b 指向同一对象。 */
void Vector3f_Cross(Vector3f_t *out, const Vector3f_t *a, const Vector3f_t *b);

/* 归一化；长度为 0 或含 NaN 时返回 0 且不修改 v。 */
uint8_t Vector3f_Normalize(Vector3f_t *v);

#endif
