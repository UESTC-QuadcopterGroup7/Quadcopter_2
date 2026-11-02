#ifndef ACCEL_CALIBRATION_H
#define ACCEL_CALIBRATION_H

#include <stdint.h>

#define ACCEL_CAL_MAX_POSES       32u
#define ACCEL_CAL_MIN_POSES        6u
#define ACCEL_CAL_MAX_ITERATIONS  40u
#define ACCEL_CAL_MAX_RMS_G        0.02f

typedef enum {
    ACCEL_CAL_OK = 0,
    ACCEL_CAL_INVALID_ARGUMENT,
    ACCEL_CAL_FULL,
    ACCEL_CAL_NOT_ENOUGH_POSES,
    ACCEL_CAL_DEGENERATE,
    ACCEL_CAL_NO_CONVERGENCE,
    ACCEL_CAL_POOR_FIT
} AccelCal_Status;

typedef struct {
    float pose_g[ACCEL_CAL_MAX_POSES][3];
    float lsb_per_g;
    uint16_t count;
} AccelCal_Data;

typedef struct {
    float bias_raw[3];       /* b：基于未补偿原始计数的三轴零偏。 */
    float scale[3];          /* k：三轴比例修正系数，无单位，必须为正。 */
    float lsb_per_g;         /* 每 1g 对应的计数，必须与采样时的量程一致。 */
    float rms_g;             /* 校准后模长与 1g 之差的均方根，单位为 g。 */
    uint16_t iterations;
} AccelCal_Result;

/* 不使用堆内存，不依赖 HAL 或 RTOS；同一份数据不支持并发访问。
 * 校准模型：corrected_g[axis] = scale[axis] * (raw[axis]-bias_raw[axis]) / lsb_per_g。
 * 仅估计各轴比例系数和零偏，不拟合轴间不正交或耦合误差。
 *
 * 调用示例（数据建议定义为静态变量，避免占用较小的 RTOS 任务栈）：
 *   static AccelCal_Data data;
 *   static AccelCal_Result result;
 *   AccelCal_Reset(&data, (float)MPU6050_ACCEL_1G_RAW);
 *   // 每个静止姿态采集 100～200 帧新产生的有效原始数据，并计算均值。
 *   // 每个姿态添加一次均值，不要每帧添加一次；姿态应覆盖 X、Y、Z 的正负方向。
 *   // 建议另外采集 12～24 个分布均匀的倾斜姿态。
 *   AccelCal_AddPose(&data, mean_ax_raw, mean_ay_raw, mean_az_raw);
 *   // 全部姿态采集完成后，求解参数并进行补偿：
 *   if (AccelCal_Solve(&data, &result) == ACCEL_CAL_OK) {
 *       AccelCal_Apply(&result, ax_raw, ay_raw, az_raw, accel_g);
 *   }
 *
 * 采样使用 MPU6050_GetRawData()，不能使用已经减去偏置的 MPU6050_GetData()。
 * 调用方负责剔除运动或振动姿态，以及饱和或 I2C 通信失败的数据帧。
 * 必须检查每个接口的返回状态；求解或补偿失败时，输出保持原值。
 * 如需掉电保存，应将成功的校准结果连同量程、版本和完整性校验信息一起保存。
 * 应用这些参数后，不要再重复减去原有的加速度偏置。
 */
AccelCal_Status AccelCal_Reset(AccelCal_Data *data, float lsb_per_g);
AccelCal_Status AccelCal_AddPose(AccelCal_Data *data,
                               float ax_raw, float ay_raw, float az_raw);
AccelCal_Status AccelCal_Solve(const AccelCal_Data *data, AccelCal_Result *result);
/* 按 step = -(J^T J)^(-1) J^T r 显式求逆计算步长的完整校准接口。
 * 输入、输出、单位及错误状态与 AccelCal_Solve() 一致；原接口仍使用 QR。
 * 调用示例：AccelCal_SolveNormal(&data, &result)。
 * 此方法对矩阵病态更敏感，可能比 QR 更早返回 ACCEL_CAL_DEGENERATE。
 */
AccelCal_Status AccelCal_SolveNormal(const AccelCal_Data *data, AccelCal_Result *result);
AccelCal_Status AccelCal_Apply(const AccelCal_Result *result,
                             float ax_raw, float ay_raw, float az_raw,
                             float accel_g[3]);

#endif
