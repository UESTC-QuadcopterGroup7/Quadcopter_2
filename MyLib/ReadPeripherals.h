#ifndef __READPERIPHERALS_H
#define __READPERIPHERALS_H

#include <stdint.h>

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

extern volatile MPU6050_Read_t  g_MPU6050;
extern volatile HMC5883L_Read_t g_HMC5883L;
extern volatile MS5611_Read_t   g_MS5611;

void ReadPeripherals_Init(void);
void ReadPeripherals_Process(void);

#endif
