#include "main.h"
#include "GY86.h"
#include "ReadPeripherals.h"
#include "UART_Set.h"
#include "ucos_ii.h"
#include <stdio.h>
#include <string.h>

/* ================================================================
 *  跨任务共享的传感器数据
 * ================================================================ */
volatile MPU6050_Read_t  g_MPU6050  = {0};
volatile HMC5883L_Read_t g_HMC5883L = {0};
volatile MS5611_Read_t   g_MS5611   = {0};

/* ================================================================
 *  本地状态变量
 * ================================================================ */

/* tick_counter: 每调用一次 Process() 自增 1，等价于 5ms 时间分辨率 */
static uint32_t tick_counter = 0;
static uint8_t mpu_calibration_pending = 1;

/* ---- MS5611 非阻塞状态机 ---- */
#if 0 /* 暂停气压计测量，保留代码以便恢复。 */
enum {
    MS5611_IDLE    = 0,
    MS5611_WAIT_D2 = 1,
    MS5611_WAIT_D1 = 2
};

#define MS5611_OSR             MS561101BA_OSR_4096   /* 最高精度 */
#define MS5611_CONV_WAIT_TICKS 3                     /* 等待 3 tick = 15ms，安全覆盖 ~9ms 转换时间 */
#define MS5611_CYCLE_TICKS     40                    /* 每 200ms 启动一次新气压测量周期 (5Hz) */

static uint8_t  ms5611_state    = MS5611_IDLE;
static uint8_t  ms5611_wait_ctr = 0;
static uint32_t ms5611_d2_raw   = 0;
static uint32_t ms5611_d1_raw   = 0;
#endif

/* ================================================================
 *  ReadPeripherals_Init
 * ================================================================ */
void ReadPeripherals_Init(void) {
    MPU6050_Init();
    HMC5883L_Init();
    // MS561101BA_Init();    /* 暂停气压计初始化：复位 + 读取 PROM */
    tick_counter = 0;
    mpu_calibration_pending = 1;
}

/* ================================================================
 *  ReadPeripherals_Process
 *
 *  由 AppTaskSensor 每 5ms 调用一次。
 *  当前仅采集 MPU6050 和 HMC5883L，MS5611 测量已暂停。
 * ================================================================ */
void ReadPeripherals_Process(void) {
    uint32_t now = tick_counter;

    /* 初始化后的第一次调用先完成校准，不发布校准期间的原始数据。 */
    if (mpu_calibration_pending != 0) {
        int16_t ax, ay, az, gx, gy, gz;

        MPU6050_CalibrationStart();
        while (MPU6050_CalibrationStatus() != 0) {
            MPU6050_GetData(&ax, &ay, &az, &gx, &gy, &gz);
            OSTimeDlyHMSM(0, 0, 0, 10);
        }
        mpu_calibration_pending = 0;
    }

    /* ============================================================
     *  1. MPU6050 —— 每次调用均读取 (5ms = 200Hz)
     * ============================================================ */
    {
        int16_t ax, ay, az, gx, gy, gz;
        MPU6050_GetData(&ax, &ay, &az, &gx, &gy, &gz);

        g_MPU6050.ax   = ax;
        g_MPU6050.ay   = ay;
        g_MPU6050.az   = az;
        g_MPU6050.gx   = gx;
        g_MPU6050.gy   = gy;
        g_MPU6050.gz   = gz;
        g_MPU6050.tick = now;
        g_MPU6050.fresh = 1;
    }

    /* ============================================================
     *  2. HMC5883L —— 与 MPU6050 一样，每次调用均读取
     * ============================================================ */
    {
        int16_t mx, my, mz;
        HMC5883L_GetData(&mx, &my, &mz);

        g_HMC5883L.mx   = mx;
        g_HMC5883L.my   = my;
        g_HMC5883L.mz   = mz;
        g_HMC5883L.tick = now;
        g_HMC5883L.fresh = 1;
    }

    #if 0 /* 暂停气压计采集、计算和串口输出。 */
    /* ============================================================
     *  3. MS5611 —— 非阻塞状态机
     *
     *  流程：IDLE → StartConversionD2 → WAIT_D2 (3 ticks)
     *       → ReadADC + StartConversionD1 → WAIT_D1 (3 ticks)
     *       → ReadADC + Calculate → 更新 g_MS5611 → IDLE
     *  每 MS5611_CYCLE_TICKS (200ms) 启动一次新周期。
     * ============================================================ */

    /* 周期触发：从 IDLE 启动新测量 */
    if ((now % MS5611_CYCLE_TICKS) == 0 && ms5611_state == MS5611_IDLE) {
        MS561101BA_StartConversionD2(MS5611_OSR);
        ms5611_state    = MS5611_WAIT_D2;
        ms5611_wait_ctr = MS5611_CONV_WAIT_TICKS;
    }

    switch (ms5611_state) {
        case MS5611_WAIT_D2:
            if (--ms5611_wait_ctr == 0) {
                ms5611_d2_raw = MS561101BA_ReadADC();
                MS561101BA_StartConversionD1(MS5611_OSR);
                ms5611_state    = MS5611_WAIT_D1;
                ms5611_wait_ctr = MS5611_CONV_WAIT_TICKS;
            }
            break;

        case MS5611_WAIT_D1:
            if (--ms5611_wait_ctr == 0) {
                ms5611_d1_raw = MS561101BA_ReadADC();

                MS561101BA_Data_t ms;
                if (MS561101BA_Calculate(ms5611_d1_raw, ms5611_d2_raw, &ms)) {
                    g_MS5611.temperature = ms.temperature;
                    g_MS5611.pressure    = ms.pressure;
                    g_MS5611.altitude    = ms.altitude;
                    g_MS5611.tick        = now;
                    g_MS5611.fresh       = 1;
                }
                ms5611_state = MS5611_IDLE;
            }
            break;

        default:
            ms5611_state = MS5611_IDLE;
            break;
    }
    #endif

    tick_counter++;
}

void ReadPeripherals_Transmit(void)
{
    MPU6050_Read_t mpu;
    HMC5883L_Read_t hmc;
    OS_CPU_SR cpu_sr;
    char buf[128];

    /* 只在复制快照时保护共享数据，格式化和串口发送允许任务抢占。 */
    OS_ENTER_CRITICAL();
    mpu = g_MPU6050;
    hmc = g_HMC5883L;
    OS_EXIT_CRITICAL();

    if (mpu.fresh != 0) {
        snprintf(buf, sizeof(buf),
                 "MPU A:%d,%d,%d G:%d,%d,%d\r\n",
                 mpu.ax, mpu.ay, mpu.az, mpu.gx, mpu.gy, mpu.gz);
        HAL_UART_Transmit(&huart1, (uint8_t *)buf, (uint16_t)strlen(buf), 1000);
    }

    if (hmc.fresh != 0) {
        snprintf(buf, sizeof(buf),
                 "HMC M:%d,%d,%d\r\n", hmc.mx, hmc.my, hmc.mz);
        HAL_UART_Transmit(&huart1, (uint8_t *)buf, (uint16_t)strlen(buf), 1000);
    }
}
