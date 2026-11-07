#include "main.h"
#include "GY86.h"
#include "ReadPeripherals.h"
#include "Attitude.h"
#include "AccelCalibration.h"
#include "ANO.h"
#include "UART_Set.h"
#include "ucos_ii.h"
#include <float.h>
#include <stdio.h>
#include <string.h>

#if ACCEL_CAL_MODE == 0 && ACCEL_CAL_PARAMS_VALID == 1
#if ACCEL_CAL_PARAMS_1G_RAW != MPU6050_ACCEL_1G_RAW
#error Accelerometer calibration does not match the configured range
#endif
#endif

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

/* ---- 发送节奏 ---- */

/* 通信任务每 10ms 调用一次 Transmit；ANO_TICK_DIV = 1 → 每拍都发姿态帧（100Hz）。 */
#define ANO_TICK_DIV      1u

/* MPU6050 陀螺量程 ±2000°/s 对应的灵敏度 */
#define MPU6050_GYRO_LSB_PER_DPS 16.4f

/* ---- 姿态解算状态 ---- */
static Attitude_t s_attitude;
static uint32_t   s_attitude_last_cyc = 0;
static uint8_t    s_attitude_ready = 0;
static uint8_t    s_hmc_div = 0;
static uint8_t    s_frame_div = 0;
static uint8_t    s_motion_div = 0;
static uint8_t    s_env_div = 0;

#if ACCEL_CAL_MODE == 0 && ACCEL_CAL_PARAMS_VALID == 1
static int16_t AccelCal_ClampRaw(float value)
{
    if (value >= 32767.0f) {
        return 32767;
    }
    if (value <= -32768.0f) {
        return -32768;
    }
    return (int16_t)(value >= 0.0f ? value + 0.5f : value - 0.5f);
}
#endif

#if ACCEL_CAL_MODE == 1
#define ACCEL_CAL_SAMPLES_PER_POSE 100u
#define ACCEL_CAL_SAMPLE_INTERVAL_MS 10u
#define ACCEL_CAL_MAX_SPAN_RAW (MPU6050_ACCEL_1G_RAW / 10)
#define ACCEL_CAL_MAX_GYRO_RAW 164
#define ACCEL_CAL_POSE_MASK_ALL 0x3fu
#define ACCEL_CAL_STATE_COLLECTING 1u
#define ACCEL_CAL_STATE_SOLVED 2u
#define ACCEL_CAL_STATE_ERROR 3u

/* F1 浮点通道：状态、姿态掩码、当前样本数、错误码、三轴比例。 */
static AccelCal_Data s_accel_cal_data;
static AccelCal_Result s_accel_cal_result;
static volatile uint8_t s_accel_cal_state;
static volatile uint8_t s_accel_cal_mask;
static volatile uint8_t s_accel_cal_error;
static volatile float s_accel_cal_output[3];
static int8_t s_accel_cal_pose = -1;
static volatile uint16_t s_accel_cal_count;
static int32_t s_accel_cal_sum[3];
static int16_t s_accel_cal_min[3];
static int16_t s_accel_cal_max[3];
static uint32_t s_accel_cal_last_ms;
static uint8_t s_accel_cal_tx_div;

/* 识别接近单轴正负 1g 的六个姿态，顺序为 +X、-X、+Y、-Y、+Z、-Z。 */
static int8_t AccelCal_DetectPose(const int16_t accel[3])
{
    int32_t magnitude[3];
    uint8_t axis;
    uint8_t largest = 0u;

    for (axis = 0u; axis < 3u; ++axis) {
        magnitude[axis] = accel[axis] < 0 ? -(int32_t)accel[axis] : (int32_t)accel[axis];
        if (magnitude[axis] > magnitude[largest]) {
            largest = axis;
        }
    }
    if (magnitude[largest] < MPU6050_ACCEL_1G_RAW * 3 / 4 ||
        magnitude[largest] > MPU6050_ACCEL_1G_RAW * 5 / 4) {
        return -1;
    }
    for (axis = 0u; axis < 3u; ++axis) {
        if (axis != largest && magnitude[axis] > MPU6050_ACCEL_1G_RAW / 2) {
            return -1;
        }
    }
    return (int8_t)(2u * largest + (accel[largest] < 0 ? 1u : 0u));
}

static void AccelCal_CaptureSample(void)
{
    int16_t accel[3], gyro[3];
    uint32_t now;
    uint8_t axis;
    int8_t pose;
    AccelCal_Status result;

    if (s_accel_cal_state != ACCEL_CAL_STATE_COLLECTING) {
        return;
    }
    now = HAL_GetTick();
    if ((uint32_t)(now - s_accel_cal_last_ms) < ACCEL_CAL_SAMPLE_INTERVAL_MS) {
        return;
    }
    s_accel_cal_last_ms = now;
    if (MPU6050_GetRawData(&accel[0], &accel[1], &accel[2],
                           &gyro[0], &gyro[1], &gyro[2]) == 0u) {
        s_accel_cal_error = 1u;
        s_accel_cal_count = 0u;
        s_accel_cal_pose = -1;
        return;
    }
    pose = AccelCal_DetectPose(accel);
    if (pose < 0 || (s_accel_cal_mask & (uint8_t)(1u << pose)) != 0u) {
        s_accel_cal_count = 0u;
        s_accel_cal_pose = -1;
        return;
    }
    for (axis = 0u; axis < 3u; ++axis) {
        if (gyro[axis] > ACCEL_CAL_MAX_GYRO_RAW || gyro[axis] < -ACCEL_CAL_MAX_GYRO_RAW ||
            accel[axis] == 32767 || accel[axis] == -32768) {
            s_accel_cal_count = 0u;
            s_accel_cal_pose = -1;
            return;
        }
    }
    if (pose != s_accel_cal_pose) {
        s_accel_cal_count = 0u;
        s_accel_cal_pose = pose;
        memset(s_accel_cal_sum, 0, sizeof(s_accel_cal_sum));
    }
    for (axis = 0u; axis < 3u; ++axis) {
        if (s_accel_cal_count == 0u) {
            s_accel_cal_min[axis] = accel[axis];
            s_accel_cal_max[axis] = accel[axis];
        } else {
            if (accel[axis] < s_accel_cal_min[axis]) { s_accel_cal_min[axis] = accel[axis]; }
            if (accel[axis] > s_accel_cal_max[axis]) { s_accel_cal_max[axis] = accel[axis]; }
        }
        if ((int32_t)s_accel_cal_max[axis] - s_accel_cal_min[axis] > ACCEL_CAL_MAX_SPAN_RAW) {
            s_accel_cal_count = 0u;
            s_accel_cal_pose = -1;
            return;
        }
        s_accel_cal_sum[axis] += accel[axis];
    }
    s_accel_cal_error = 0u;
    if (++s_accel_cal_count < ACCEL_CAL_SAMPLES_PER_POSE) {
        return;
    }
    result = AccelCal_AddPose(&s_accel_cal_data,
                             (float)s_accel_cal_sum[0] / ACCEL_CAL_SAMPLES_PER_POSE,
                             (float)s_accel_cal_sum[1] / ACCEL_CAL_SAMPLES_PER_POSE,
                             (float)s_accel_cal_sum[2] / ACCEL_CAL_SAMPLES_PER_POSE);
    if (result != ACCEL_CAL_OK) {
        s_accel_cal_error = (uint8_t)result + 1u;
        s_accel_cal_state = ACCEL_CAL_STATE_ERROR;
        return;
    }
    s_accel_cal_mask |= (uint8_t)(1u << pose);
    s_accel_cal_count = 0u;
    s_accel_cal_pose = -1;
    if (s_accel_cal_mask == ACCEL_CAL_POSE_MASK_ALL) {
        result = AccelCal_Solve(&s_accel_cal_data, &s_accel_cal_result);
        if (result == ACCEL_CAL_OK) {
            for (axis = 0u; axis < 3u; ++axis) {
                s_accel_cal_output[axis] = s_accel_cal_result.scale[axis];
            }
        }
        s_accel_cal_error = (result == ACCEL_CAL_OK) ? 0u : (uint8_t)result + 1u;
        s_accel_cal_state = (result == ACCEL_CAL_OK) ? ACCEL_CAL_STATE_SOLVED : ACCEL_CAL_STATE_ERROR;
    }
}
#endif

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

#if ACCEL_CAL_MODE == 1
    s_accel_cal_state = (AccelCal_Reset(&s_accel_cal_data, (float)MPU6050_ACCEL_1G_RAW)
                         == ACCEL_CAL_OK) ? ACCEL_CAL_STATE_COLLECTING : ACCEL_CAL_STATE_ERROR;
    s_accel_cal_mask = 0u;
    s_accel_cal_count = 0u;
    s_accel_cal_error = 0u;
    s_accel_cal_pose = -1;
    s_accel_cal_last_ms = HAL_GetTick();
#endif

    /*
     * 打开 DWT 周期计数器，用来测两次采样的间隔。
     * HAL_GetTick() 只有 1ms 分辨率，采样周期降到 2ms 左右以后，
     * 用它算 dt 的误差会到 25%，积分出来的角度会抖。
     */
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
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

#if ACCEL_CAL_MODE == 1
    (void)now;
    AccelCal_CaptureSample();
    return;
#endif

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
     *  1. MPU6050 —— 每次调用均读取
     *
     *  I2C 提速 + 突发读之后，一次读取约 1ms，加上任务延时循环约 2ms，
     *  实际采样率接近 400Hz（MPU 自身输出 200Hz，多读的是同一份数据）。
     * ============================================================ */
    {
        int16_t ax, ay, az, gx, gy, gz;
#if ACCEL_CAL_MODE == 0 && ACCEL_CAL_PARAMS_VALID == 1
        {
            if (!(ACCEL_CAL_SCALE_X > 0.0f && ACCEL_CAL_SCALE_X <= FLT_MAX &&
                  ACCEL_CAL_SCALE_Y > 0.0f && ACCEL_CAL_SCALE_Y <= FLT_MAX &&
                  ACCEL_CAL_SCALE_Z > 0.0f && ACCEL_CAL_SCALE_Z <= FLT_MAX) ||
                MPU6050_GetRawData(&ax, &ay, &az, &gx, &gy, &gz) == 0u) {
                g_MPU6050.fresh = 0u;
                g_Attitude.fresh = 0u;
                s_attitude_ready = 0u;
                return;
            }
            ax = AccelCal_ClampRaw(((float)ax - (float)g_MpuOffset.ax) * ACCEL_CAL_SCALE_X);
            ay = AccelCal_ClampRaw(((float)ay - (float)g_MpuOffset.ay) * ACCEL_CAL_SCALE_Y);
            /* 原开机校准存储 az_mean - 1g；恢复平均值后按实际方向保留 1g。 */
            az = AccelCal_ClampRaw(((float)az - ((float)g_MpuOffset.az +
                                                 (float)MPU6050_ACCEL_1G_RAW)) *
                                   ACCEL_CAL_SCALE_Z +
                                   (float)(ACCEL_CAL_START_Z_SIGN * MPU6050_ACCEL_1G_RAW));
            gx = AccelCal_ClampRaw((float)((int32_t)gx - g_MpuOffset.gx));
            gy = AccelCal_ClampRaw((float)((int32_t)gy - g_MpuOffset.gy));
            gz = AccelCal_ClampRaw((float)((int32_t)gz - g_MpuOffset.gz));
        }
#else
        MPU6050_GetData(&ax, &ay, &az, &gx, &gy, &gz);
#endif

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
     *  2. HMC5883L —— 每 4 次调用读一次
     *
     *  磁力计本身输出率只有 15Hz（CONFIG_A 设的是 8 次平均），
     *  读得再快也拿不到新数据，却要多花一次 I2C 事务的时间，
     *  所以降到约 1/4 采样率。
     * ============================================================ */
    if (++s_hmc_div >= 4u) {
        int16_t mx, my, mz;

        s_hmc_div = 0;
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
     *  输入是已做零偏补偿的原始计数。dt 取自 DWT 周期计数器（微秒级），
     *  采样周期不固定也不影响积分精度；滤波器内部还会限幅 dt。
     * ============================================================ */
    {
        int16_t accel[3];
        int16_t gyro[3];
        int16_t mag[3];
        const int16_t *mag_ptr = 0;
        uint32_t now_cyc = DWT->CYCCNT;

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
                s_attitude_last_cyc = now_cyc;
                PublishAttitude(&s_attitude, now, flags);
            }
        } else {
            float dt = (float)(uint32_t)(now_cyc - s_attitude_last_cyc) / (float)SystemCoreClock;
            uint8_t flags = Attitude_UpdateRaw(&s_attitude, accel, gyro, mag_ptr, dt);

            s_attitude_last_cyc = now_cyc;
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
    float acc_ms2[3];
    float gyr_dps[3];
    int16_t mag[3];

#if ACCEL_CAL_MODE == 1
    {
        float values[7];
        uint8_t i;

        if (++s_accel_cal_tx_div < 40u) {
            return;
        }
        s_accel_cal_tx_div = 0u;
        OS_ENTER_CRITICAL();
        values[0] = (float)s_accel_cal_state;
        values[1] = (float)s_accel_cal_mask;
        values[2] = (float)s_accel_cal_count;
        values[3] = (float)s_accel_cal_error;
        for (i = 0u; i < 3u; ++i) {
            values[i + 4u] = s_accel_cal_output[i];
        }
        OS_EXIT_CRITICAL();
        ANO_SendFloats(0xF1u, values, 7u);
        return;
    }
#endif

    /* 只在复制快照时保护共享数据，格式化和串口发送允许任务抢占。 */
    OS_ENTER_CRITICAL();
    mpu = g_MPU6050;
    hmc = g_HMC5883L;
    att = g_Attitude;
    OS_EXIT_CRITICAL();

    /* ---- 飞控固定帧 0x01 / 0x02 / 0x03 ----
     *
     * 这三帧喂的是上位机波形页里 FC_ACC_* / FC_GYR_* / FC_MAG_* / FC_ATT_*
     * 那些通道（通道名和顺序都是协议写死的），同时也是“飞控状态”页
     * 3D 模型、罗盘和 ROL/PIT/YAW 的数据源。
     *
     * 注意：这里不依赖 att.fresh，传感器一上电就开始发，避免没有姿态时
     * 整个串口静默。
     */
    if (++s_frame_div >= ANO_TICK_DIV) {
        s_frame_div = 0;

        /* 姿态帧优先：3D 模型和 ROL/PIT/YAW 全靠它，100Hz。 */
        if (att.fresh != 0) {
            ANO_SendFC_Attitude(att.roll, att.pitch, att.yaw);
        }

        /* 运动帧 50Hz：加速度 / 角速度，只喂波形，不需要那么快。 */
        if (++s_motion_div >= 2u) {
            s_motion_div = 0;

            /* ±16g 档 2048 LSB/g；±2000°/s 档 16.4 LSB/(°/s) */
            acc_ms2[0] = (float)mpu.ax / (float)MPU6050_ACCEL_1G_RAW * 9.80665f;
            acc_ms2[1] = (float)mpu.ay / (float)MPU6050_ACCEL_1G_RAW * 9.80665f;
            acc_ms2[2] = (float)mpu.az / (float)MPU6050_ACCEL_1G_RAW * 9.80665f;

            gyr_dps[0] = (float)mpu.gx / MPU6050_GYRO_LSB_PER_DPS;
            gyr_dps[1] = (float)mpu.gy / MPU6050_GYRO_LSB_PER_DPS;
            gyr_dps[2] = (float)mpu.gz / MPU6050_GYRO_LSB_PER_DPS;

            if (mpu.fresh != 0u) {
                ANO_SendFC_AccGyr(acc_ms2, gyr_dps, 0u);
            }
        }

        /* 环境帧 25Hz：磁力变化慢，气压高度暂未启用。 */
        if (++s_env_div >= 4u) {
            s_env_div = 0;
            mag[0] = hmc.mx;
            mag[1] = hmc.my;
            mag[2] = hmc.mz;
            ANO_SendFC_MagBaro(mag, 0.0f, 0.0f, 0u,
                               (uint8_t)((g_HmcAddressAck == 0) ? 1u : 0u));
        }
    }

#if 0 /* 保留原始文本输出。 */
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
#endif
}
