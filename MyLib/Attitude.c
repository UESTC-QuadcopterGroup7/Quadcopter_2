#include <math.h>
#include "Attitude.h"
#include "GY86.h"

/*
 * 传感器原始计数 → 物理量
 *
 * 陀螺仪量程在 GY86.c 的 MPU6050_Init() 里写死为 GYRO_CONFIG = 0x18，
 * 即 ±2000°/s、16.4 LSB/(°/s)。加速度的 1g 计数由 GY86.h 中的
 * MPU6050_ACCEL_1G_RAW 按当前加速度量程算出，改量程时只需改那一处。
 */
#define ATTITUDE_GYRO_LSB_PER_DPS   (16.4f)
#define ATTITUDE_ACCEL_LSB_PER_G    ((float)MPU6050_ACCEL_1G_RAW)

/* 磁场向量（原始计数）小于该值时视为无效：HMC5883L 读失败会返回全 0xFF。 */
#define ATTITUDE_MAG_MIN_LSB        (100.0f)

/* ================================================================
 *  内部工具
 * ================================================================ */

static float Attitude_Clampf(float value, float min, float max)
{
    if (value < min) {
        return min;
    }
    if (value > max) {
        return max;
    }
    return value;
}

/* 同时拦住 NaN 与 ±Inf。 */
static uint8_t Attitude_IsUsable(float value)
{
    return (uint8_t)((value == value) && (fabsf(value) < 1.0e30f));
}

static uint8_t Attitude_VectorIsUsable(const Vector3f_t *v)
{
    return (uint8_t)(Attitude_IsUsable(v->x) && Attitude_IsUsable(v->y) && Attitude_IsUsable(v->z));
}

/* 用加速度计求横滚、俯仰；静止时 a ≈ (0, 0, 1) g。 */
static void Attitude_TiltFromAccel(const Vector3f_t *accel, float *roll, float *pitch)
{
    *roll = atan2f(accel->y, accel->z);
    *pitch = atan2f(accel->x, sqrtf(accel->y * accel->y + accel->z * accel->z));
}

/* ================================================================
 *  目标函数与雅可比矩阵
 *
 *  约定：J 按"行优先、每行 4 个元素"存放，第 r 行对应 f[r]，
 *        第 c 列对应四元数分量 (w, x, y, z)。
 * ================================================================ */

/*
 * 重力项：f = v(q) - â，v(q) = R(q)ᵀ·(0,0,1) 是当前姿态下加速度计应测到的方向。
 *
 *      v = ( 2(xz - wy), 2(yz + wx), 1 - 2x² - 2y² )
 */
static void Attitude_GravityTerms(const Quaternion_t *q, const Vector3f_t *accel, float f[3], float J[12])
{
    Vector3f_t up;
    Vector3f_t v;
    float w = q->w;
    float x = q->x;
    float y = q->y;
    float z = q->z;

    up.x = 0.0f;
    up.y = 0.0f;
    up.z = 1.0f;
    Quaternion_RotateVectorInverse(&v, q, &up);

    f[0] = v.x - accel->x;
    f[1] = v.y - accel->y;
    f[2] = v.z - accel->z;

    /* ∂v/∂(w, x, y, z) */
    J[0]  = -2.0f * y;  J[1]  =  2.0f * z;  J[2]  = -2.0f * w;  J[3]  =  2.0f * x;
    J[4]  =  2.0f * x;  J[5]  =  2.0f * w;  J[6]  =  2.0f * z;  J[7]  =  2.0f * y;
    J[8]  =  0.0f;      J[9]  = -4.0f * x;  J[10] = -4.0f * y;  J[11] =  0.0f;
}

/*
 * 磁场项：f = w(q) - m̂，其中
 *
 *      h = R(q)·m̂                       观测磁场转到大地系
 *      b = ( |h_xy|, 0, h_z )           把磁场水平分量归到大地系 X 轴（磁北）
 *      w(q) = R(q)ᵀ·b                   参考磁场在机体系下的投影
 *
 * b 在求导时视为常数（Madgwick 原文的处理方式）。磁场几乎竖直时航向不可观测，
 * 此时返回 0，调用方跳过这一项。
 */
static uint8_t Attitude_MagTerms(const Quaternion_t *q, const Vector3f_t *mag, float f[3], float J[12])
{
    Vector3f_t h;
    Vector3f_t b;
    Vector3f_t v;
    float w = q->w;
    float x = q->x;
    float y = q->y;
    float z = q->z;

    Quaternion_RotateVector(&h, q, mag);

    b.x = sqrtf(h.x * h.x + h.y * h.y);
    b.y = 0.0f;
    b.z = h.z;

    if (!(b.x > ATTITUDE_MAG_MIN_HORIZONTAL)) {
        return 0;
    }

    Quaternion_RotateVectorInverse(&v, q, &b);

    f[0] = v.x - mag->x;
    f[1] = v.y - mag->y;
    f[2] = v.z - mag->z;

    /* ∂w/∂(w, x, y, z)，b = (bx, 0, bz) */
    J[0]  = -2.0f * y * b.z;
    J[1]  =  2.0f * z * b.z;
    J[2]  = -4.0f * y * b.x - 2.0f * w * b.z;
    J[3]  = -4.0f * z * b.x + 2.0f * x * b.z;

    J[4]  = -2.0f * z * b.x + 2.0f * x * b.z;
    J[5]  =  2.0f * y * b.x + 2.0f * w * b.z;
    J[6]  =  2.0f * x * b.x + 2.0f * z * b.z;
    J[7]  = -2.0f * w * b.x + 2.0f * y * b.z;

    J[8]  =  2.0f * y * b.x;
    J[9]  =  2.0f * z * b.x - 4.0f * x * b.z;
    J[10] =  2.0f * w * b.x - 4.0f * y * b.z;
    J[11] =  2.0f * x * b.x;

    return 1;
}

/* ================================================================
 *  初始化与配置
 * ================================================================ */

void Attitude_Reset(Attitude_t *att)
{
    if (att == 0) {
        return;
    }

    Quaternion_Identity(&att->q);
    att->euler.roll = 0.0f;
    att->euler.pitch = 0.0f;
    att->euler.yaw = 0.0f;
    att->beta = ATTITUDE_BETA_DEFAULT;
    att->accel_valid = 0;
    att->mag_valid = 0;
}

void Attitude_SetBeta(Attitude_t *att, float beta)
{
    if (att == 0) {
        return;
    }

    att->beta = (beta > 0.0f) ? beta : 0.0f;
}

uint8_t Attitude_Init(Attitude_t *att, const Vector3f_t *accel, const Vector3f_t *mag)
{
    Vector3f_t m;
    Vector3f_t h;
    float norm;
    float roll;
    float pitch;
    float yaw = 0.0f;

    if (att == 0 || accel == 0) {
        return 0;
    }

    Attitude_Reset(att);

    if (Attitude_VectorIsUsable(accel) == 0) {
        return 0;
    }

    norm = Vector3f_Length(accel);
    if (!(norm > ATTITUDE_ACCEL_MIN_G) || !(norm < ATTITUDE_ACCEL_MAX_G)) {
        return 0;
    }

    Attitude_TiltFromAccel(accel, &roll, &pitch);
    Quaternion_FromEuler(&att->q, roll, pitch, 0.0f);

    if (mag != 0 && Attitude_VectorIsUsable(mag) != 0) {
        m = *mag;
        if (Vector3f_Normalize(&m) != 0) {
            /*
             * 先用零偏航的姿态把磁场转到大地系，此时磁场水平分量与大地系
             * X 轴（北）的夹角就是待求的偏航角（右转为正）。
             */
            Quaternion_RotateVector(&h, &att->q, &m);
            yaw = atan2f(h.y, h.x);
            att->mag_valid = 1;
        }
    }

    Quaternion_FromEuler(&att->q, roll, pitch, yaw);
    Quaternion_ToEuler(&att->q, &att->euler);
    return 1;
}

uint8_t Attitude_InitRaw(Attitude_t *att, const int16_t accel[3], const int16_t mag[3])
{
    Vector3f_t a;
    Vector3f_t m;

    if (att == 0 || accel == 0) {
        return 0;
    }

    a.x = (float)accel[0] / ATTITUDE_ACCEL_LSB_PER_G;
    a.y = (float)accel[1] / ATTITUDE_ACCEL_LSB_PER_G;
    a.z = (float)accel[2] / ATTITUDE_ACCEL_LSB_PER_G;

    if (mag == 0) {
        return Attitude_Init(att, &a, 0);
    }

    /* 磁场只需要方向，因此直接传原始计数，不必先做 Gauss 换算。 */
    m.x = (float)mag[0];
    m.y = (float)mag[1];
    m.z = (float)mag[2];
    return Attitude_Init(att, &a, &m);
}

/* ================================================================
 *  姿态更新（Madgwick 梯度下降）
 * ================================================================ */

uint8_t Attitude_Update(Attitude_t *att, const Vector3f_t *gyro, const Vector3f_t *accel,
                        const Vector3f_t *mag, float dt)
{
    Vector3f_t a;
    Vector3f_t m;
    float f[6];
    float J[24];
    float grad[4];
    float norm;
    Quaternion_t qdot;
    uint8_t rows;
    uint8_t r;
    uint8_t c;
    uint8_t flags;

    if (att == 0 || gyro == 0 || accel == 0) {
        return 0;
    }

    if (!(dt > 0.0f) || Attitude_IsUsable(dt) == 0) {
        return 0;
    }
    if (Attitude_VectorIsUsable(gyro) == 0) {
        return 0;
    }

    dt = Attitude_Clampf(dt, ATTITUDE_DT_MIN, ATTITUDE_DT_MAX);

    flags = ATTITUDE_FLAG_UPDATED;
    att->accel_valid = 0;
    att->mag_valid = 0;
    rows = 0;

    /* ---- 1. 加速度计：重力方向观测 ---- */
    norm = Attitude_VectorIsUsable(accel) ? Vector3f_Length(accel) : 0.0f;
    if (norm > ATTITUDE_ACCEL_MIN_G && norm < ATTITUDE_ACCEL_MAX_G) {
        a.x = accel->x / norm;
        a.y = accel->y / norm;
        a.z = accel->z / norm;

        Attitude_GravityTerms(&att->q, &a, &f[0], &J[0]);
        rows = 3;

        att->accel_valid = 1;
        flags |= ATTITUDE_FLAG_ACCEL;
    }

    /* ---- 2. 磁力计：磁场方向观测 ---- */
    if (mag != 0 && Attitude_VectorIsUsable(mag) != 0) {
        m = *mag;
        if (Vector3f_Normalize(&m) != 0) {
            if (Attitude_MagTerms(&att->q, &m, &f[rows], &J[rows * 4]) != 0) {
                rows += 3;
                att->mag_valid = 1;
                flags |= ATTITUDE_FLAG_MAG;
            }
        }
    }

    /* ---- 3. 梯度 ∇f = Jᵀ·f，并按 β 归一化 ---- */
    grad[0] = 0.0f;
    grad[1] = 0.0f;
    grad[2] = 0.0f;
    grad[3] = 0.0f;

    if (rows > 0 && att->beta > 0.0f) {
        for (r = 0; r < rows; r++) {
            for (c = 0; c < 4; c++) {
                grad[c] += J[r * 4 + c] * f[r];
            }
        }

        norm = sqrtf(grad[0] * grad[0] + grad[1] * grad[1] + grad[2] * grad[2] + grad[3] * grad[3]);
        if (norm > QUATERNION_EPS) {
            /* 残差为零时不做修正，避免 0/0。 */
            norm = att->beta / norm;
            grad[0] *= norm;
            grad[1] *= norm;
            grad[2] *= norm;
            grad[3] *= norm;
        } else {
            grad[0] = 0.0f;
            grad[1] = 0.0f;
            grad[2] = 0.0f;
            grad[3] = 0.0f;
        }
    }

    /* ---- 4. q̇ = ½·q ⊗ ω − β·∇f/|∇f|，然后一阶积分并归一化 ---- */
    Quaternion_Derivative(&qdot, &att->q, gyro->x, gyro->y, gyro->z);

    att->q.w += (qdot.w - grad[0]) * dt;
    att->q.x += (qdot.x - grad[1]) * dt;
    att->q.y += (qdot.y - grad[2]) * dt;
    att->q.z += (qdot.z - grad[3]) * dt;

    if (Quaternion_Normalize(&att->q) == 0) {
        Quaternion_Identity(&att->q);
    }

    Quaternion_ToEuler(&att->q, &att->euler);
    return flags;
}

uint8_t Attitude_UpdateRaw(Attitude_t *att, const int16_t accel[3], const int16_t gyro[3],
                           const int16_t mag[3], float dt)
{
    Vector3f_t a;
    Vector3f_t g;
    Vector3f_t m;
    const Vector3f_t *mag_ptr = 0;

    if (att == 0 || accel == 0 || gyro == 0) {
        return 0;
    }

    a.x = (float)accel[0] / ATTITUDE_ACCEL_LSB_PER_G;
    a.y = (float)accel[1] / ATTITUDE_ACCEL_LSB_PER_G;
    a.z = (float)accel[2] / ATTITUDE_ACCEL_LSB_PER_G;

    g.x = (float)gyro[0] * (QUATERNION_DEG_TO_RAD / ATTITUDE_GYRO_LSB_PER_DPS);
    g.y = (float)gyro[1] * (QUATERNION_DEG_TO_RAD / ATTITUDE_GYRO_LSB_PER_DPS);
    g.z = (float)gyro[2] * (QUATERNION_DEG_TO_RAD / ATTITUDE_GYRO_LSB_PER_DPS);

    if (mag != 0) {
        m.x = (float)mag[0];
        m.y = (float)mag[1];
        m.z = (float)mag[2];
        if (Vector3f_Length(&m) > ATTITUDE_MAG_MIN_LSB) {
            mag_ptr = &m;
        }
    }

    return Attitude_Update(att, &g, &a, mag_ptr, dt);
}

/* ================================================================
 *  读取
 * ================================================================ */

void Attitude_GetEuler(const Attitude_t *att, EulerAngles_t *euler)
{
    if (att == 0 || euler == 0) {
        return;
    }
    *euler = att->euler;
}

void Attitude_GetEulerDegrees(const Attitude_t *att, float *roll_deg, float *pitch_deg, float *yaw_deg)
{
    if (att == 0) {
        return;
    }

    if (roll_deg != 0) {
        *roll_deg = att->euler.roll * QUATERNION_RAD_TO_DEG;
    }
    if (pitch_deg != 0) {
        *pitch_deg = att->euler.pitch * QUATERNION_RAD_TO_DEG;
    }
    if (yaw_deg != 0) {
        *yaw_deg = att->euler.yaw * QUATERNION_RAD_TO_DEG;
    }
}
