/* 主机测试编译命令：gcc -std=c99 -Wall -Wextra -Werror -ITests/stubs -IMyLib
 *   Tests/test_accel_calibration.c MyLib/AccelCalibration.c MyLib/GY86.c
 *   -lm -o test_accel_calibration.exe
 */
#include "AccelCalibration.h"
#include "GY86.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static const float known_bias[3] = {0.045f, -0.032f, 0.018f};
static const float known_scale[3] = {1.035f, 0.972f, 1.018f};
typedef AccelCal_Status (*CalibrationSolver)(const AccelCal_Data *, AccelCal_Result *);
static unsigned int rng = 7u;
static int ack_number, fail_ack, byte_number, stop_count, nack_count;
static const uint8_t sensor_frame[14] = {
    0x80, 0x01, 0x00, 0x02, 0x7F, 0xFE, 0x12, 0x34,
    0xFF, 0xFE, 0x00, 0x05, 0x80, 0x00
};

uint32_t HAL_GetTick(void) { return 0u; }
void HAL_Delay(uint32_t milliseconds) { (void)milliseconds; }
void MyI2C_Init(void) {}
void MyI2C_Start(void) {}
void MyI2C_Stop(void) { ++stop_count; }
void MyI2C_SendByte(uint8_t value) { (void)value; }
uint8_t MyI2C_ReceiveAck(void) { return ++ack_number == fail_ack ? 1u : 0u; }
uint8_t MyI2C_ReceiveByte(void)
{
    assert(byte_number < 14);
    return sensor_frame[byte_number++];
}
void MyI2C_SendAck(uint8_t value)
{
    assert(value == (byte_number == 14 ? 1u : 0u));
    if (value) { ++nack_count; }
}

static float noise(void)
{
    rng = rng * 1664525u + 1013904223u;
    return ((float)(rng & 0xffffu) / 65535.0f - 0.5f) * 0.001f;
}

static void test_recovery(float sensitivity, int noisy, CalibrationSolver solve)
{
    AccelCal_Data data;
    AccelCal_Result result;
    float raw[3], corrected[3];
    int x, y, z;
    unsigned int axis;
    assert(AccelCal_Reset(&data, sensitivity) == ACCEL_CAL_OK);
    for (x = -1; x <= 1; ++x) {
        for (y = -1; y <= 1; ++y) {
            for (z = -1; z <= 1; ++z) {
                float norm = sqrtf((float)(x*x + y*y + z*z));
                float direction[3];
                if (norm == 0.0f) { continue; }
                direction[0] = (float)x / norm;
                direction[1] = (float)y / norm;
                direction[2] = (float)z / norm;
                for (axis = 0; axis < 3u; ++axis) {
                    raw[axis] = sensitivity * (direction[axis] / known_scale[axis] +
                                known_bias[axis] + (noisy ? noise() : 0.0f));
                }
                assert(AccelCal_AddPose(&data, raw[0], raw[1], raw[2]) == ACCEL_CAL_OK);
            }
        }
    }
    assert(solve(&data, &result) == ACCEL_CAL_OK);
    /* 使用同一批数据比较显式求逆和 QR 的最终参数，检查两种步长算法的一致性。 */
    if (solve == AccelCal_SolveNormal) {
        AccelCal_Result qr_result;
        assert(AccelCal_Solve(&data, &qr_result) == ACCEL_CAL_OK);
        for (axis = 0; axis < 3u; ++axis) {
            assert(fabsf(result.bias_raw[axis] - qr_result.bias_raw[axis]) / sensitivity < 1.0e-5f);
            assert(fabsf(result.scale[axis] - qr_result.scale[axis]) < 1.0e-5f);
        }
    }
    assert(result.rms_g < 0.001f);
    for (axis = 0; axis < 3u; ++axis) {
        assert(fabsf(result.bias_raw[axis] / sensitivity - known_bias[axis]) < 0.001f);
        assert(fabsf(result.scale[axis] - known_scale[axis]) < 0.001f);
    }
    /* 使用未参与拟合的倾斜姿态验证补偿效果。 */
    raw[0] = sensitivity * (0.36f / known_scale[0] + known_bias[0]);
    raw[1] = sensitivity * (-0.48f / known_scale[1] + known_bias[1]);
    raw[2] = sensitivity * (0.80f / known_scale[2] + known_bias[2]);
    assert(AccelCal_Apply(&result, raw[0], raw[1], raw[2], corrected) == ACCEL_CAL_OK);
    assert(fabsf(corrected[0] - 0.36f) < 0.001f);
    assert(fabsf(corrected[1] + 0.48f) < 0.001f);
    assert(fabsf(corrected[2] - 0.80f) < 0.001f);
}

static void test_failures(CalibrationSolver solve)
{
    AccelCal_Data data;
    AccelCal_Result result, before;
    float output[3] = {7.0f, 8.0f, 9.0f};
    unsigned int i;
    int x, y, z;
    assert(AccelCal_Reset(NULL, 2048.0f) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(AccelCal_Reset(&data, 0.0f) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(AccelCal_Reset(&data, 2048.0f) == ACCEL_CAL_OK);
    memset(&result, 0x5a, sizeof(result));
    before = result;
    assert(solve(NULL, &result) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(solve(&data, NULL) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(solve(&data, &result) == ACCEL_CAL_NOT_ENOUGH_POSES);
    assert(memcmp(&result, &before, sizeof(result)) == 0);
    assert(AccelCal_AddPose(&data, NAN, 0.0f, 0.0f) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(AccelCal_AddPose(&data, 32767.0f, 0.0f, 0.0f) == ACCEL_CAL_INVALID_ARGUMENT);
    for (i = 0; i < ACCEL_CAL_MAX_POSES; ++i) {
        assert(AccelCal_AddPose(&data, 0.0f, 0.0f, 2048.0f) == ACCEL_CAL_OK);
    }
    assert(AccelCal_AddPose(&data, 0.0f, 0.0f, 2048.0f) == ACCEL_CAL_FULL);
    assert(solve(&data, &result) == ACCEL_CAL_DEGENERATE);
    assert(memcmp(&result, &before, sizeof(result)) == 0);
    assert(AccelCal_Reset(&data, 2048.0f) == ACCEL_CAL_OK);
    /* 八个角点覆盖所有轴，但各轴分量的平方相同，无法独立确定三个比例系数。
     * 两种求解方法都必须识别并拒绝这组退化数据。 */
    for (x = -1; x <= 1; x += 2) {
        for (y = -1; y <= 1; y += 2) {
            for (z = -1; z <= 1; z += 2) {
                assert(AccelCal_AddPose(&data, 1182.4f*x, 1182.4f*y, 1182.4f*z) == ACCEL_CAL_OK);
            }
        }
    }
    assert(solve(&data, &result) == ACCEL_CAL_DEGENERATE);
    assert(memcmp(&result, &before, sizeof(result)) == 0);
    memset(&result, 0, sizeof(result));
    assert(AccelCal_Apply(&result, 0, 0, 2048, output) == ACCEL_CAL_INVALID_ARGUMENT);
    assert(output[0] == 7 && output[1] == 8 && output[2] == 9);
}

static void test_six_faces_and_bad_fit(CalibrationSolver solve)
{
    AccelCal_Data data;
    AccelCal_Result result, before;
    int axis, sign;
    assert(AccelCal_Reset(&data, 2048.0f) == ACCEL_CAL_OK);
    for (axis = 0; axis < 3; ++axis) {
        for (sign = -1; sign <= 1; sign += 2) {
            float v[3] = {0, 0, 0};
            v[axis] = 2048.0f * sign;
            assert(AccelCal_AddPose(&data, v[0], v[1], v[2]) == ACCEL_CAL_OK);
        }
    }
    assert(solve(&data, &result) == ACCEL_CAL_OK);
    assert(result.rms_g < 1.0e-6f && result.scale[0] == 1.0f);
    before = result;
    /* 同一方向上相互矛盾的模长无法同时拟合到同一个椭球面。 */
    assert(AccelCal_AddPose(&data, 2800.0f, 0, 0) == ACCEL_CAL_OK);
    assert(solve(&data, &result) == ACCEL_CAL_POOR_FIT);
    assert(memcmp(&result, &before, sizeof(result)) == 0);
}

static void test_raw_frame(void)
{
    int16_t v[6];
    int fail, i;
    for (fail = 0; fail <= 3; ++fail) {
        ack_number = byte_number = stop_count = nack_count = 0;
        fail_ack = fail;
        for (i = 0; i < 6; ++i) { v[i] = 123; }
        assert(MPU6050_GetRawData(&v[0], &v[1], &v[2], &v[3], &v[4], &v[5]) == (fail == 0));
        assert(stop_count == 1);
        if (fail == 0) {
            assert(byte_number == 14 && nack_count == 1);
            assert(v[0] == -32767 && v[1] == 2 && v[2] == 32766);
            assert(v[3] == -2 && v[4] == 5 && v[5] == -32768);
        } else {
            for (i = 0; i < 6; ++i) { assert(v[i] == 123); }
            assert(byte_number == 0);
        }
    }
    assert(MPU6050_GetRawData(NULL, &v[1], &v[2], &v[3], &v[4], &v[5]) == 0);
}

int main(void)
{
    unsigned int run, method;
    const float ranges[4] = {2048, 4096, 8192, 16384};
    const CalibrationSolver solvers[2] = {AccelCal_Solve, AccelCal_SolveNormal};
    for (method = 0; method < 2u; ++method) {
        for (run = 0; run < 4u; ++run) { test_recovery(ranges[run], 0, solvers[method]); }
        for (run = 0; run < 100u; ++run) { test_recovery(ranges[run % 4u], 1, solvers[method]); }
        test_failures(solvers[method]);
        test_six_faces_and_bad_fit(solvers[method]);
    }
    test_raw_frame();
    puts("PASS: QR and explicit inverse, parameter recovery, 100 noisy datasets per method,");
    puts("      solver agreement, held-out poses, all ranges,");
    puts("      six faces, invalid/degenerate data, poor fit, raw frame and I2C failures.");
    return 0;
}
