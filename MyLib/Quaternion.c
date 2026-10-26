#include <math.h>
#include "Quaternion.h"

/* ================================================================
 *  内部工具
 * ================================================================ */

static float Quaternion_Clampf(float value, float min, float max)
{
    if (value < min) {
        return min;
    }
    if (value > max) {
        return max;
    }
    return value;
}

/* ================================================================
 *  构造
 * ================================================================ */

void Quaternion_Identity(Quaternion_t *q)
{
    if (q == 0) {
        return;
    }
    q->w = 1.0f;
    q->x = 0.0f;
    q->y = 0.0f;
    q->z = 0.0f;
}

void Quaternion_FromAxisAngle(Quaternion_t *q, float axis_x, float axis_y, float axis_z, float angle)
{
    float norm;
    float half;
    float s;

    if (q == 0) {
        return;
    }

    norm = sqrtf(axis_x * axis_x + axis_y * axis_y + axis_z * axis_z);
    if (!(norm > QUATERNION_EPS)) {
        Quaternion_Identity(q);
        return;
    }

    half = 0.5f * angle;
    s = sinf(half) / norm;

    q->w = cosf(half);
    q->x = axis_x * s;
    q->y = axis_y * s;
    q->z = axis_z * s;
}

void Quaternion_FromEuler(Quaternion_t *q, float roll, float pitch, float yaw)
{
    Quaternion_t qx;
    Quaternion_t qy;
    Quaternion_t qz;
    Quaternion_t tmp;
    float half_roll;
    float half_pitch;
    float half_yaw;

    if (q == 0) {
        return;
    }

    half_roll  = 0.5f * roll;
    /* 地理系 Z 轴向上，pitch / yaw 取负号才能得到"抬头为正、右转为正"的直观约定。 */
    half_pitch = -0.5f * pitch;
    half_yaw   = -0.5f * yaw;

    qx.w = cosf(half_roll);
    qx.x = sinf(half_roll);
    qx.y = 0.0f;
    qx.z = 0.0f;

    qy.w = cosf(half_pitch);
    qy.x = 0.0f;
    qy.y = sinf(half_pitch);
    qy.z = 0.0f;

    qz.w = cosf(half_yaw);
    qz.x = 0.0f;
    qz.y = 0.0f;
    qz.z = sinf(half_yaw);

    /* R = Rz(-yaw) · Ry(-pitch) · Rx(roll)，而 Hamilton 积的施加顺序相反。 */
    Quaternion_Multiply(&tmp, &qz, &qy);
    Quaternion_Multiply(q, &tmp, &qx);
    (void)Quaternion_Normalize(q);
}

void Quaternion_FromTwoVectors(Quaternion_t *q, const Vector3f_t *from, const Vector3f_t *to)
{
    Vector3f_t f;
    Vector3f_t t;
    Vector3f_t axis;
    float dot;

    if (q == 0 || from == 0 || to == 0) {
        return;
    }

    Quaternion_Identity(q);

    f = *from;
    t = *to;
    if (Vector3f_Normalize(&f) == 0 || Vector3f_Normalize(&t) == 0) {
        return;
    }

    dot = Vector3f_Dot(&f, &t);
    if (dot > 0.999999f) {
        /* 方向相同或夹角极小，无需旋转。 */
        return;
    }

    if (dot < -0.999999f) {
        /* 方向相反：转轴可取任意与 f 垂直的方向，这里挑一个数值上稳定的。 */
        if (fabsf(f.x) <= fabsf(f.y) && fabsf(f.x) <= fabsf(f.z)) {
            axis.x = 0.0f;
            axis.y = -f.z;
            axis.z = f.y;
        } else if (fabsf(f.y) <= fabsf(f.z)) {
            axis.x = -f.z;
            axis.y = 0.0f;
            axis.z = f.x;
        } else {
            axis.x = -f.y;
            axis.y = f.x;
            axis.z = 0.0f;
        }
        (void)Vector3f_Normalize(&axis);

        q->w = 0.0f;
        q->x = axis.x;
        q->y = axis.y;
        q->z = axis.z;
        return;
    }

    Vector3f_Cross(&axis, &f, &t);
    q->w = 1.0f + dot;
    q->x = axis.x;
    q->y = axis.y;
    q->z = axis.z;
    (void)Quaternion_Normalize(q);
}

void Quaternion_FromRotationMatrix(Quaternion_t *q, const float m[9])
{
    float trace;
    float s;

    if (q == 0 || m == 0) {
        return;
    }

    trace = m[0] + m[4] + m[8];

    if (trace > 0.0f) {
        s = sqrtf(trace + 1.0f) * 2.0f;
        q->w = 0.25f * s;
        q->x = (m[7] - m[5]) / s;
        q->y = (m[2] - m[6]) / s;
        q->z = (m[3] - m[1]) / s;
    } else if (m[0] > m[4] && m[0] > m[8]) {
        s = sqrtf(1.0f + m[0] - m[4] - m[8]) * 2.0f;
        q->w = (m[7] - m[5]) / s;
        q->x = 0.25f * s;
        q->y = (m[1] + m[3]) / s;
        q->z = (m[2] + m[6]) / s;
    } else if (m[4] > m[8]) {
        s = sqrtf(1.0f + m[4] - m[0] - m[8]) * 2.0f;
        q->w = (m[2] - m[6]) / s;
        q->x = (m[1] + m[3]) / s;
        q->y = 0.25f * s;
        q->z = (m[5] + m[7]) / s;
    } else {
        s = sqrtf(1.0f + m[8] - m[0] - m[4]) * 2.0f;
        q->w = (m[3] - m[1]) / s;
        q->x = (m[2] + m[6]) / s;
        q->y = (m[5] + m[7]) / s;
        q->z = 0.25f * s;
    }

    (void)Quaternion_Normalize(q);
}

/* ================================================================
 *  转换
 * ================================================================ */

void Quaternion_ToEuler(const Quaternion_t *q, EulerAngles_t *euler)
{
    float r00;
    float r10;
    float r20;
    float r21;
    float r22;

    if (q == 0 || euler == 0) {
        return;
    }

    /* 由 q 直接写出旋转矩阵中需要的几个元素，避免先算出整个矩阵。 */
    r00 = 1.0f - 2.0f * (q->y * q->y + q->z * q->z);
    r10 = 2.0f * (q->x * q->y + q->w * q->z);
    r20 = 2.0f * (q->x * q->z - q->w * q->y);
    r21 = 2.0f * (q->y * q->z + q->w * q->x);
    r22 = 1.0f - 2.0f * (q->x * q->x + q->y * q->y);

    euler->roll  = atan2f(r21, r22);
    euler->pitch = asinf(Quaternion_Clampf(r20, -1.0f, 1.0f));
    euler->yaw   = atan2f(-r10, r00);
}

void Quaternion_ToRotationMatrix(const Quaternion_t *q, float m[9])
{
    float xx;
    float yy;
    float zz;
    float xy;
    float xz;
    float yz;
    float wx;
    float wy;
    float wz;

    if (q == 0 || m == 0) {
        return;
    }

    xx = q->x * q->x;
    yy = q->y * q->y;
    zz = q->z * q->z;
    xy = q->x * q->y;
    xz = q->x * q->z;
    yz = q->y * q->z;
    wx = q->w * q->x;
    wy = q->w * q->y;
    wz = q->w * q->z;

    m[0] = 1.0f - 2.0f * (yy + zz);
    m[1] = 2.0f * (xy - wz);
    m[2] = 2.0f * (xz + wy);

    m[3] = 2.0f * (xy + wz);
    m[4] = 1.0f - 2.0f * (xx + zz);
    m[5] = 2.0f * (yz - wx);

    m[6] = 2.0f * (xz - wy);
    m[7] = 2.0f * (yz + wx);
    m[8] = 1.0f - 2.0f * (xx + yy);
}

/* ================================================================
 *  基本运算
 * ================================================================ */

void Quaternion_Multiply(Quaternion_t *out, const Quaternion_t *a, const Quaternion_t *b)
{
    Quaternion_t result;

    if (out == 0 || a == 0 || b == 0) {
        return;
    }

    /* 先存到局部变量，保证 out 与 a 或 b 相同（原地相乘）时结果正确。 */
    result.w = a->w * b->w - a->x * b->x - a->y * b->y - a->z * b->z;
    result.x = a->w * b->x + a->x * b->w + a->y * b->z - a->z * b->y;
    result.y = a->w * b->y - a->x * b->z + a->y * b->w + a->z * b->x;
    result.z = a->w * b->z + a->x * b->y - a->y * b->x + a->z * b->w;

    *out = result;
}

void Quaternion_Conjugate(Quaternion_t *out, const Quaternion_t *q)
{
    if (out == 0 || q == 0) {
        return;
    }

    out->w =  q->w;
    out->x = -q->x;
    out->y = -q->y;
    out->z = -q->z;
}

void Quaternion_Inverse(Quaternion_t *out, const Quaternion_t *q)
{
    float norm_sq;

    if (out == 0 || q == 0) {
        return;
    }

    norm_sq = q->w * q->w + q->x * q->x + q->y * q->y + q->z * q->z;
    if (!(norm_sq > QUATERNION_EPS)) {
        Quaternion_Identity(out);
        return;
    }

    out->w =  q->w / norm_sq;
    out->x = -q->x / norm_sq;
    out->y = -q->y / norm_sq;
    out->z = -q->z / norm_sq;
}

float Quaternion_Norm(const Quaternion_t *q)
{
    if (q == 0) {
        return 0.0f;
    }
    return sqrtf(q->w * q->w + q->x * q->x + q->y * q->y + q->z * q->z);
}

uint8_t Quaternion_Normalize(Quaternion_t *q)
{
    float norm;
    float inv;

    if (q == 0) {
        return 0;
    }

    norm = Quaternion_Norm(q);
    /* 写成 !(norm > eps) 可以同时拦住 0 和 NaN。 */
    if (!(norm > QUATERNION_EPS)) {
        return 0;
    }

    inv = 1.0f / norm;
    q->w *= inv;
    q->x *= inv;
    q->y *= inv;
    q->z *= inv;
    return 1;
}

float Quaternion_Dot(const Quaternion_t *a, const Quaternion_t *b)
{
    if (a == 0 || b == 0) {
        return 0.0f;
    }
    return a->w * b->w + a->x * b->x + a->y * b->y + a->z * b->z;
}

float Quaternion_AngleBetween(const Quaternion_t *a, const Quaternion_t *b)
{
    float dot;

    dot = fabsf(Quaternion_Dot(a, b));
    dot = Quaternion_Clampf(dot, -1.0f, 1.0f);
    return 2.0f * acosf(dot);
}

void Quaternion_Slerp(Quaternion_t *out, const Quaternion_t *a, const Quaternion_t *b, float t)
{
    Quaternion_t target;
    float dot;
    float theta;
    float sin_theta;
    float s0;
    float s1;

    if (out == 0 || a == 0 || b == 0) {
        return;
    }

    target = *b;
    dot = Quaternion_Dot(a, &target);

    /* q 与 -q 表示同一姿态，取点积为正的那一半才能走最短路径。 */
    if (dot < 0.0f) {
        target.w = -target.w;
        target.x = -target.x;
        target.y = -target.y;
        target.z = -target.z;
        dot = -dot;
    }

    if (dot > 0.9995f) {
        /* 夹角很小时 sin(theta) 接近 0，退化为线性插值再归一化。 */
        out->w = a->w + t * (target.w - a->w);
        out->x = a->x + t * (target.x - a->x);
        out->y = a->y + t * (target.y - a->y);
        out->z = a->z + t * (target.z - a->z);
        (void)Quaternion_Normalize(out);
        return;
    }

    theta = acosf(Quaternion_Clampf(dot, -1.0f, 1.0f));
    sin_theta = sinf(theta);
    s0 = sinf((1.0f - t) * theta) / sin_theta;
    s1 = sinf(t * theta) / sin_theta;

    out->w = s0 * a->w + s1 * target.w;
    out->x = s0 * a->x + s1 * target.x;
    out->y = s0 * a->y + s1 * target.y;
    out->z = s0 * a->z + s1 * target.z;
    (void)Quaternion_Normalize(out);
}

/* ================================================================
 *  向量旋转
 * ================================================================ */

void Quaternion_RotateVector(Vector3f_t *out, const Quaternion_t *q, const Vector3f_t *v)
{
    Vector3f_t u;
    Vector3f_t t;
    Vector3f_t c;
    float s;

    if (out == 0 || q == 0 || v == 0) {
        return;
    }

    /*
     * 展开 q ⊗ (0,v) ⊗ q* 得：
     *     v' = v + 2w(u × v) + 2u × (u × v)        u = (x, y, z)
     * 比做两次四元数乘法少一次乘法，且不需要把 v 扩成四元数。
     */
    u.x = q->x;
    u.y = q->y;
    u.z = q->z;
    s = q->w;

    Vector3f_Cross(&t, &u, v);
    t.x *= 2.0f;
    t.y *= 2.0f;
    t.z *= 2.0f;

    Vector3f_Cross(&c, &u, &t);

    out->x = v->x + s * t.x + c.x;
    out->y = v->y + s * t.y + c.y;
    out->z = v->z + s * t.z + c.z;
}

void Quaternion_RotateVectorInverse(Vector3f_t *out, const Quaternion_t *q, const Vector3f_t *v)
{
    Quaternion_t conjugate;

    if (out == 0 || q == 0 || v == 0) {
        return;
    }

    Quaternion_Conjugate(&conjugate, q);
    Quaternion_RotateVector(out, &conjugate, v);
}

/* ================================================================
 *  与角速度相关的积分
 * ================================================================ */

void Quaternion_Derivative(Quaternion_t *qdot, const Quaternion_t *q, float wx, float wy, float wz)
{
    Quaternion_t omega;

    if (qdot == 0 || q == 0) {
        return;
    }

    /* qdot = ½ · q ⊗ (0, ω) */
    omega.w = 0.0f;
    omega.x = wx;
    omega.y = wy;
    omega.z = wz;

    Quaternion_Multiply(qdot, q, &omega);
    qdot->w *= 0.5f;
    qdot->x *= 0.5f;
    qdot->y *= 0.5f;
    qdot->z *= 0.5f;
}

void Quaternion_IntegrateBodyRate(Quaternion_t *q, float wx, float wy, float wz, float dt)
{
    Quaternion_t delta;
    float theta;
    float half;
    float s;

    if (q == 0 || !(dt > 0.0f)) {
        return;
    }

    /* 本次采样转过的角度 θ = |ω|·dt */
    theta = sqrtf(wx * wx + wy * wy + wz * wz) * dt;

    if (theta > 1.0e-4f) {
        half = 0.5f * theta;
        s = sinf(half) / theta;         /* ω 未归一化，除以 θ 顺便完成归一化 */
        delta.w = cosf(half);
        delta.x = wx * dt * s;
        delta.y = wy * dt * s;
        delta.z = wz * dt * s;
    } else {
        /* 小角度用二阶展开，避免除以极小的 θ 带来的精度损失。 */
        delta.w = 1.0f - 0.125f * theta * theta;
        delta.x = 0.5f * wx * dt;
        delta.y = 0.5f * wy * dt;
        delta.z = 0.5f * wz * dt;
    }

    /* 角速度定义在机体系，因此增量右乘。 */
    Quaternion_Multiply(q, q, &delta);
    (void)Quaternion_Normalize(q);
}

/* ================================================================
 *  三维向量工具
 * ================================================================ */

float Vector3f_Length(const Vector3f_t *v)
{
    if (v == 0) {
        return 0.0f;
    }
    return sqrtf(v->x * v->x + v->y * v->y + v->z * v->z);
}

float Vector3f_Dot(const Vector3f_t *a, const Vector3f_t *b)
{
    if (a == 0 || b == 0) {
        return 0.0f;
    }
    return a->x * b->x + a->y * b->y + a->z * b->z;
}

void Vector3f_Cross(Vector3f_t *out, const Vector3f_t *a, const Vector3f_t *b)
{
    Vector3f_t result;

    if (out == 0 || a == 0 || b == 0) {
        return;
    }

    result.x = a->y * b->z - a->z * b->y;
    result.y = a->z * b->x - a->x * b->z;
    result.z = a->x * b->y - a->y * b->x;

    *out = result;
}

uint8_t Vector3f_Normalize(Vector3f_t *v)
{
    float norm;
    float inv;

    if (v == 0) {
        return 0;
    }

    norm = Vector3f_Length(v);
    if (!(norm > QUATERNION_EPS)) {
        return 0;
    }

    inv = 1.0f / norm;
    v->x *= inv;
    v->y *= inv;
    v->z *= inv;
    return 1;
}
