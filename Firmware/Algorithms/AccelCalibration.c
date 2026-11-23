#include "AccelCalibration.h"
#include <float.h>
#include <math.h>
#include <stddef.h>
#include <string.h>

#define PARAMS 6u
#define STEP_TOL 1.0e-6f
#define RANK_TOL 1.0e-5f
#define NORMAL_PIVOT_TOL 1.0e-6f

/* 自行检查有限浮点数，避免依赖 ARMCC 5 对 isfinite() 的支持情况。 */
static int finite_float(float x)
{
    return x == x && x <= FLT_MAX && x >= -FLT_MAX;
}

static int valid_sensitivity(float value)
{
    /* 输入数据为有符号 16 位加速度计原始计数的均值。 */
    return finite_float(value) && value >= 1.0f && value <= 32768.0f;
}

static int valid_raw(float value)
{
    return finite_float(value) && value > -32768.0f && value < 32767.0f;
}
// 残差计算
static float residual(const float sample[3], const float p[PARAMS])
{
    float sum = -1.0f;
    unsigned int axis;
    for (axis = 0; axis < 3u; ++axis) {
        float value = p[axis + 3u] * (sample[axis] - p[axis]);
        sum += value * value;
    }
    return sum;
}
//对每组测的数据进行残差计算
static float cost(const AccelCal_Data *data, const float p[PARAMS])
{
    float sum = 0.0f;
    unsigned int i;
    for (i = 0; i < data->count; ++i) {
        float r = residual(data->pose_g[i], p);
        sum += r * r;
    }
    return sum;
}

/* 对增广矩阵 [J | -r] 逐行进行 Givens 旋转 QR 分解，避免构造或求逆 J^T J。
 * 内部零偏以 g 为单位，使六个参数对应的雅可比列具有相近的数值尺度。
 */
static int gauss_newton_step(const AccelCal_Data *data,
                            const float p[PARAMS], float step[PARAMS])
{
    float qr[PARAMS][PARAMS + 1u] = {{0.0f}};
    float max_diagonal = 0.0f;
    unsigned int i, j, k;
    int row;

    for (i = 0; i < data->count; ++i) {
        float values[PARAMS + 1u];
        for (j = 0; j < 3u; ++j) {
            float d = data->pose_g[i][j] - p[j];
            float s = p[j + 3u];
            values[j] = -2.0f * s * s * d;
            values[j + 3u] = 2.0f * s * d * d;
        }
        values[PARAMS] = -residual(data->pose_g[i], p);
        for (j = 0; j < PARAMS; ++j) {
            float length, c, s;
            if (values[j] == 0.0f) {
                continue;
            }
            length = sqrtf(qr[j][j] * qr[j][j] + values[j] * values[j]);
            if (!finite_float(length) || length == 0.0f) {
                return 0;
            }
            c = qr[j][j] / length;
            s = values[j] / length;
            for (k = j; k <= PARAMS; ++k) {
                float old = qr[j][k];
                qr[j][k] = c * old + s * values[k];
                values[k] = -s * old + c * values[k];
            }
        }
    }
    for (j = 0; j < PARAMS; ++j) {
        float d = fabsf(qr[j][j]);
        if (d > max_diagonal) {
            max_diagonal = d;
        }
    }
    if (max_diagonal == 0.0f) {
        return 0;
    }
    for (row = (int)PARAMS - 1; row >= 0; --row) {
        float value = qr[row][PARAMS];
        if (fabsf(qr[row][row]) <= RANK_TOL * max_diagonal) {
            return 0;
        }
        for (j = (unsigned int)row + 1u; j < PARAMS; ++j) {
            value -= qr[row][j] * step[j];
        }
        step[row] = value / qr[row][row];
        if (!finite_float(step[row])) {
            return 0;
        }
    }
    return 1;
}

/* 按公式计算单轮增量：step = -(J^T J)^(-1) J^T r。
 * 先累计 J^T J 和 J^T r，再对 [J^T J | I] 进行带部分选主元的
 * Gauss-Jordan 消元，得到 [I | (J^T J)^(-1)]，最后完成矩阵乘法。
 * 参数顺序为 [bx, by, bz, kx, ky, kz]，内部零偏仍以 g 为单位。
 * 显式求逆对退化数据更敏感，因此单独检查主元大小和浮点数有效性。
 */
static int gauss_newton_step_normal(const AccelCal_Data *data,
                                   const float p[PARAMS], float step[PARAMS])
{
    float augmented[PARAMS][2u * PARAMS] = {{0.0f}};
    float jtr[PARAMS] = {0.0f};
    float calculated_step[PARAMS];
    float matrix_scale = 0.0f;
    unsigned int i, j, k, row;

    /* 每个姿态贡献雅可比的一行；逐项相加即可构造两个矩阵乘积。 */
    for (i = 0; i < data->count; ++i) {
        float jacobian[PARAMS];
        float r = residual(data->pose_g[i], p);
        for (j = 0; j < 3u; ++j) {
            float d = data->pose_g[i][j] - p[j];
            float s = p[j + 3u];
            jacobian[j] = -2.0f * s * s * d;
            jacobian[j + 3u] = 2.0f * s * d * d;
        }
        for (j = 0; j < PARAMS; ++j) {
            jtr[j] += jacobian[j] * r;
            for (k = 0; k < PARAMS; ++k) {
                augmented[j][k] += jacobian[j] * jacobian[k];
            }
        }
    }

    /* 左半部分为 J^T J，右半部分初始化为单位矩阵 I。 */
    for (j = 0; j < PARAMS; ++j) {
        if (!finite_float(jtr[j])) { return 0; }
        for (k = 0; k < PARAMS; ++k) {
            float value = fabsf(augmented[j][k]);
            if (!finite_float(value)) { return 0; }
            if (value > matrix_scale) { matrix_scale = value; }
        }
        augmented[j][j + PARAMS] = 1.0f;
    }
    if (matrix_scale == 0.0f) { return 0; }

    for (j = 0; j < PARAMS; ++j) {
        unsigned int pivot_row = j;
        float pivot_size = fabsf(augmented[j][j]);
        float pivot;

        /* 在当前列的剩余行中，选择绝对值最大的元素作主元。 */
        for (row = j + 1u; row < PARAMS; ++row) {
            float value = fabsf(augmented[row][j]);
            if (value > pivot_size) {
                pivot_size = value;
                pivot_row = row;
            }
        }
        if (pivot_size <= NORMAL_PIVOT_TOL * matrix_scale) { return 0; }
        if (pivot_row != j) {
            for (k = 0; k < 2u * PARAMS; ++k) {
                float temporary = augmented[j][k];
                augmented[j][k] = augmented[pivot_row][k];
                augmented[pivot_row][k] = temporary;
            }
        }

        /* 主元行除以主元，使当前对角元素变为 1。 */
        pivot = augmented[j][j];
        for (k = 0; k < 2u * PARAMS; ++k) {
            augmented[j][k] /= pivot;
            if (!finite_float(augmented[j][k])) { return 0; }
        }
        augmented[j][j] = 1.0f;

        /* 消去当前列中除主元以外的所有元素，两侧矩阵同步变换。 */
        for (row = 0; row < PARAMS; ++row) {
            float factor;
            if (row == j) { continue; }
            factor = augmented[row][j];
            for (k = 0; k < 2u * PARAMS; ++k) {
                augmented[row][k] -= factor * augmented[j][k];
                if (!finite_float(augmented[row][k])) { return 0; }
            }
            augmented[row][j] = 0.0f;
        }
    }

    /* 右半部分已经是逆矩阵；乘以 J^T r，并应用公式最前面的负号。 */
    for (j = 0; j < PARAMS; ++j) {
        float value = 0.0f;
        for (k = 0; k < PARAMS; ++k) {
            value -= augmented[j][k + PARAMS] * jtr[k];
        }
        if (!finite_float(value)) { return 0; }
        calculated_step[j] = value;
    }
    memcpy(step, calculated_step, sizeof(calculated_step));
    return 1;
}

AccelCal_Status AccelCal_Reset(AccelCal_Data *data, float lsb_per_g)
{
    if (data == NULL || !valid_sensitivity(lsb_per_g)) {
        return ACCEL_CAL_INVALID_ARGUMENT;
    }
    memset(data, 0, sizeof(*data));
    data->lsb_per_g = lsb_per_g;
    return ACCEL_CAL_OK;
}

AccelCal_Status AccelCal_AddPose(AccelCal_Data *data,
                               float ax_raw, float ay_raw, float az_raw)
{
    if (data == NULL || !valid_sensitivity(data->lsb_per_g) ||
        data->count > ACCEL_CAL_MAX_POSES ||
        !valid_raw(ax_raw) || !valid_raw(ay_raw) || !valid_raw(az_raw)) {
        return ACCEL_CAL_INVALID_ARGUMENT;
    }
    if (data->count == ACCEL_CAL_MAX_POSES) {
        return ACCEL_CAL_FULL;
    }
    data->pose_g[data->count][0] = ax_raw / data->lsb_per_g;
    data->pose_g[data->count][1] = ay_raw / data->lsb_per_g;
    data->pose_g[data->count][2] = az_raw / data->lsb_per_g;
    ++data->count;
    return ACCEL_CAL_OK;
}

/* 两个公开求解接口共用采样检查、初值、步长回退和收敛判断。
 * normal_equations 为 0 时使用 QR；为 1 时显式计算正规矩阵的逆。
 */
static AccelCal_Status solve_calibration(const AccelCal_Data *data,
                                        AccelCal_Result *result,
                                        uint8_t normal_equations)
{
    float p[PARAMS] = {0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f};
    float current_cost;
    AccelCal_Result fitted;
    unsigned int i, axis, iteration;
    int converged = 0;

    if (data == NULL || result == NULL || !valid_sensitivity(data->lsb_per_g) ||
        data->count > ACCEL_CAL_MAX_POSES) {
        return ACCEL_CAL_INVALID_ARGUMENT;
    }
    if (data->count < ACCEL_CAL_MIN_POSES) {
        return ACCEL_CAL_NOT_ENOUGH_POSES;
    }
    for (axis = 0; axis < 3u; ++axis) {
        float low = FLT_MAX, high = -FLT_MAX;
        for (i = 0; i < data->count; ++i) {
            float v = data->pose_g[i][axis];
            if (!finite_float(v) || fabsf(v) > 32768.0f) {
                return ACCEL_CAL_INVALID_ARGUMENT;
            }
            if (v < low) { low = v; }
            if (v > high) { high = v; }
        }
        /* 每个轴都必须覆盖足够的正向和负向重力分量。 */
        if (low > -0.5f || high < 0.5f) {
            return ACCEL_CAL_DEGENERATE;
        }
        p[axis] = (high + low) * 0.5f;
    }
    current_cost = cost(data, p);
    for (iteration = 0; iteration < ACCEL_CAL_MAX_ITERATIONS; ++iteration) {
        float step[PARAMS], candidate[PARAMS];
        float max_step = 0.0f, alpha = 1.0f;
        unsigned int trial;
        int accepted = 0;
        int step_ok = normal_equations ? gauss_newton_step_normal(data, p, step)
                                       : gauss_newton_step(data, p, step);
        if (!step_ok) {
            return ACCEL_CAL_DEGENERATE;
        }
        for (i = 0; i < PARAMS; ++i) {
            if (fabsf(step[i]) > max_step) { max_step = fabsf(step[i]); }
        }
        if (max_step < STEP_TOL) {
            converged = 1;
            break;
        }
        for (trial = 0; trial < 16u; ++trial) {
            float new_cost;
            int valid = 1;
            for (i = 0; i < PARAMS; ++i) {
                candidate[i] = p[i] + alpha * step[i];
                if (!finite_float(candidate[i]) ||
                    (i >= 3u && candidate[i] <= 0.0f)) { valid = 0; }
            }
            new_cost = valid ? cost(data, candidate) : FLT_MAX;
            if (finite_float(new_cost) && new_cost < current_cost) {
                memcpy(p, candidate, sizeof(p));
                current_cost = new_cost;
                accepted = 1;
                break;
            }
            alpha *= 0.5f;
        }
        if (!accepted) {
            return ACCEL_CAL_NO_CONVERGENCE;
        }
    }
    if (!converged) {
        return ACCEL_CAL_NO_CONVERGENCE;
    }
    memset(&fitted, 0, sizeof(fitted));
    for (axis = 0; axis < 3u; ++axis) {
        fitted.bias_raw[axis] = p[axis] * data->lsb_per_g;
        fitted.scale[axis] = p[axis + 3u];
    }
    for (i = 0; i < data->count; ++i) {
        float e = sqrtf(residual(data->pose_g[i], p) + 1.0f) - 1.0f;
        fitted.rms_g += e * e;
    }
    fitted.rms_g = sqrtf(fitted.rms_g / (float)data->count);
    if (!finite_float(fitted.rms_g) || fitted.rms_g > ACCEL_CAL_MAX_RMS_G) {
        return ACCEL_CAL_POOR_FIT;
    }
    fitted.lsb_per_g = data->lsb_per_g;
    fitted.iterations = (uint16_t)(iteration + 1u);
    *result = fitted;
    return ACCEL_CAL_OK;
}

AccelCal_Status AccelCal_Solve(const AccelCal_Data *data, AccelCal_Result *result)
{
    return solve_calibration(data, result, 0u);
}

AccelCal_Status AccelCal_SolveNormal(const AccelCal_Data *data, AccelCal_Result *result)
{
    return solve_calibration(data, result, 1u);
}

AccelCal_Status AccelCal_Apply(const AccelCal_Result *result,
                             float ax_raw, float ay_raw, float az_raw,
                             float accel_g[3])
{
    float raw[3], corrected[3];
    unsigned int axis;
    if (result == NULL || accel_g == NULL ||
        !valid_sensitivity(result->lsb_per_g) ||
        !valid_raw(ax_raw) || !valid_raw(ay_raw) || !valid_raw(az_raw)) {
        return ACCEL_CAL_INVALID_ARGUMENT;
    }
    raw[0] = ax_raw; raw[1] = ay_raw; raw[2] = az_raw;
    for (axis = 0; axis < 3u; ++axis) {
        if (!finite_float(result->bias_raw[axis]) ||
            !finite_float(result->scale[axis]) || result->scale[axis] <= 0.0f) {
            return ACCEL_CAL_INVALID_ARGUMENT;
        }
        corrected[axis] = result->scale[axis] *
            (raw[axis] - result->bias_raw[axis]) / result->lsb_per_g;
        if (!finite_float(corrected[axis])) { return ACCEL_CAL_INVALID_ARGUMENT; }
    }
    memcpy(accel_g, corrected, sizeof(corrected));
    return ACCEL_CAL_OK;
}
