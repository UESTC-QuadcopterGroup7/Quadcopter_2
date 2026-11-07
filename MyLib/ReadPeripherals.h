#ifndef __READPERIPHERALS_H
#define __READPERIPHERALS_H

#include <stdint.h>

/*
 * 0：正常启动；1：只采集六姿态求比例系数，禁止连接电调动力电源。
 * 模式 1 跳过开机零偏校准，发送 ANO 0xF1 的 7 个 float，小端：
 * 状态、姿态掩码、当前样本数、错误码、scale X/Y/Z。
 * 状态 1=采集、2=成功、3=失败。姿态掩码 bit 0..5 依次为
 * +X、-X、+Y、-Y、+Z、-Z（加速度原始读数的符号）。
 * 错误码 0=无、1=I2C 读取失败、其他=AccelCal_Status + 1。
 * 结果保存在内存并重复发送，上位机需自行记录；断电后丢失。
 */
#define ACCEL_CAL_MODE 0

/* 将校准输出的三个比例系数填入后设为 1；正常启动仍进行零偏校准。 */
#define ACCEL_CAL_PARAMS_VALID 0
#define ACCEL_CAL_PARAMS_1G_RAW 2048
/* 启动校准时水平静止的 Z 轴原始读数方向：-1 或 +1。 */
#define ACCEL_CAL_START_Z_SIGN (-1)
#define ACCEL_CAL_SCALE_X 1.0f
#define ACCEL_CAL_SCALE_Y 1.0f
#define ACCEL_CAL_SCALE_Z 1.0f

#if (ACCEL_CAL_MODE != 0) && (ACCEL_CAL_MODE != 1)
#error ACCEL_CAL_MODE must be 0 or 1
#endif
#if (ACCEL_CAL_PARAMS_VALID != 0) && (ACCEL_CAL_PARAMS_VALID != 1)
#error ACCEL_CAL_PARAMS_VALID must be 0 or 1
#endif
#if (ACCEL_CAL_START_Z_SIGN != -1) && (ACCEL_CAL_START_Z_SIGN != 1)
#error ACCEL_CAL_START_Z_SIGN must be -1 or 1
#endif

/*
 * 传感器共享数据结构体
 * 由 AppTaskSensor (prio 6) 写入，其他任务读取。
 * volatile 防止编译器跨任务抢占时使用寄存器缓存旧值。
 */

typedef struct {
    int16_t ax, ay, az;        // 加速度计原始值
    int16_t gx, gy, gz;        // 陀螺仪原始值
    uint32_t tick;             // 采样时刻 tick_counter（每 tick = 5ms）
    uint8_t  fresh;            // 新数据标志：写入方置1，读取方清零
} MPU6050_Read_t;

typedef struct {
    int16_t mx, my, mz;        // 磁力计原始值
    uint32_t tick;
    uint8_t  fresh;
} HMC5883L_Read_t;

typedef struct {
    float    temperature;      // 温度 (°C)
    float    pressure;         // 气压 (Pa)
    float    altitude;         // 海拔 (m)
    uint32_t tick;
    uint8_t  fresh;
} MS5611_Read_t;

/*
 * 姿态快照：Madgwick 四元数解算结果（见 Attitude.h）。
 * 角度单位为度；坐标系与符号约定见 Quaternion.h。
 */
typedef struct {
    float    roll;             // 横滚 (°)，右滚为正
    float    pitch;            // 俯仰 (°)，抬头为正
    float    yaw;              // 偏航 (°)，右转为正，即罗盘航向（北 0°，东 +90°）
    uint32_t tick;             // 采样时刻 tick_counter
    uint8_t  fresh;            // 新数据标志：写入方置1
    uint8_t  flags;            // Attitude 更新标志，见 ATTITUDE_FLAG_*
} Attitude_Read_t;

extern volatile MPU6050_Read_t  g_MPU6050;
extern volatile HMC5883L_Read_t g_HMC5883L;
extern volatile MS5611_Read_t   g_MS5611;
extern volatile Attitude_Read_t g_Attitude;

void ReadPeripherals_Init(void);
void ReadPeripherals_Process(void);
void ReadPeripherals_Transmit(void);

#endif
