#include "main.h"
#include "GY86.h"
#include "ReadPeripherals.h"
#include "Attitude.h"
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
volatile Attitude_Read_t g_Attitude = {0};

/* ================================================================
 *  本地状态变量
 * ================================================================ */

/* tick_counter: 每调用一次 Process() 自增 1，等价于 5ms 时间分辨率 */
static uint32_t tick_counter = 0;
static uint8_t mpu_calibration_pending = 1;

/* ---- 姿态解算状态 ---- */
static Attitude_t s_attitude;
static uint32_t   s_attitude_last_ms = 0;
static uint8_t    s_attitude_ready = 0;
static uint8_t    s_attitude_tx_div = 0;

/* 通信任务每 10ms 调用一次 Transmit，每 5 次发送一帧姿态，即约 20Hz。 */
#define ATTITUDE_TX_DIV   5u

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
 *  PublishAttitude
 *
 *  把姿态解算结果换算成角度后写入共享结构体。
 * ================================================================ */
static void PublishAttitude(const Attitude_t *att, uint32_t tick, uint8_t flags)
{
    float roll_deg;
    float pitch_deg;
    float yaw_deg;

    Attitude_GetEulerDegrees(att, &roll_deg, &pitch_deg, &yaw_deg);

    g_Attitude.roll  = roll_deg;
    g_Attitude.pitch = pitch_deg;
    g_Attitude.yaw   = yaw_deg;
    g_Attitude.tick  = tick;
    g_Attitude.flags = flags;
    g_Attitude.fresh = 1;
}

/* ================================================================
 *  ReadPeripherals_Process
 *
 *  由 AppTaskSensor 循环调用（间隔 1ms 延时 + I2C 读取时间）。
 *  采集 MPU6050 和 HMC5883L，并用 Madgwick 滤波解算姿态；
 *  MS5611 测量已暂停。
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

    /* ============================================================
     *  3. 姿态解算 —— Madgwick 梯度下降滤波（四元数）
     *
     *  输入是已做零偏补偿的原始计数，dt 取自 HAL_GetTick()，因此采样周期
     *  不必固定；代价是 dt 只有 1ms 分辨率。滤波器内部会限幅 dt。
     * ============================================================ */
    {
        int16_t accel[3];
        int16_t gyro[3];
        int16_t mag[3];
        const int16_t *mag_ptr = 0;
        uint32_t now_ms = HAL_GetTick();

        accel[0] = g_MPU6050.ax;
        accel[1] = g_MPU6050.ay;
        accel[2] = g_MPU6050.az;

        gyro[0] = g_MPU6050.gx;
        gyro[1] = g_MPU6050.gy;
        gyro[2] = g_MPU6050.gz;

        if (g_HmcAddressAck == 0) {
            /*
             * 磁力计必须映射到与加速度计、陀螺仪相同的机体系后才能参与解算。
             * GY-86 模块上 HMC5883L 与 MPU6050 的轴向是否一致要以实物为准，
             * 这里按两者同轴处理；若实测航向随横滚变化，请在此调整顺序或符号。
             */
            mag[0] = g_HMC5883L.mx;
            mag[1] = g_HMC5883L.my;
            mag[2] = g_HMC5883L.mz;
            mag_ptr = mag;
        }

        if (s_attitude_ready == 0) {
            /* 第一个可信样本：先对准水平与航向，之后才进入滤波更新。 */
            if (Attitude_InitRaw(&s_attitude, accel, mag_ptr) != 0) {
                uint8_t flags = ATTITUDE_FLAG_ACCEL;

                if (s_attitude.mag_valid != 0) {
                    flags |= ATTITUDE_FLAG_MAG;
                }
                s_attitude_ready = 1;
                s_attitude_last_ms = now_ms;
                PublishAttitude(&s_attitude, now, flags);
            }
        } else {
            float dt = (float)(uint32_t)(now_ms - s_attitude_last_ms) * 0.001f;
            uint8_t flags = Attitude_UpdateRaw(&s_attitude, accel, gyro, mag_ptr, dt);

            s_attitude_last_ms = now_ms;
            if (flags != 0) {
                PublishAttitude(&s_attitude, now, flags);
            }
        }
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
    Attitude_Read_t att;
    OS_CPU_SR cpu_sr;
    char buf[128];

    /* 只在复制快照时保护共享数据，格式化和串口发送允许任务抢占。 */
    OS_ENTER_CRITICAL();
    mpu = g_MPU6050;
    hmc = g_HMC5883L;
    att = g_Attitude;
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

    /*
     * 姿态帧约 30 字节，每 10ms 发一帧会明显挤占 115200 的带宽，
     * 因此每 ATTITUDE_TX_DIV 次发送一帧（约 20Hz），角度单位是度。
     */
    if (att.fresh != 0) {
        if (++s_attitude_tx_div >= ATTITUDE_TX_DIV) {
            s_attitude_tx_div = 0;
            snprintf(buf, sizeof(buf),
                     "ATT R:%.2f P:%.2f Y:%.2f\r\n",
                     (double)att.roll, (double)att.pitch, (double)att.yaw);
            HAL_UART_Transmit(&huart1, (uint8_t *)buf, (uint16_t)strlen(buf), 1000);
        }
    }
}
