#include "main.h"
#include "ucos_ii.h"
#include "app_cfg.h"
#include "GPIO_Set.h"
// #include "OLED.h"
#include "BLDC.h"
#include "Receive_IC.h"
#include "GY86.h"
#include "UART_Set.h"
#include "ReadPeripherals.h"
#include "ANO.h"

#if RC_MOTOR_MIN_US != BLDC_MIN_US || RC_MOTOR_MAX_US != BLDC_MAX_US || \
    RC_MOTOR_OFF_US != BLDC_OFF_US
#error RC mixer and BLDC pulse ranges must match
#endif

TIM_HandleTypeDef htim3;
UART_HandleTypeDef huart1;

static OS_STK AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE];

#if ACCEL_CAL_MODE == 0
static OS_STK AppTaskControlStk[APP_CFG_CONTROL_TASK_STK_SIZE];
static FC_Control_t s_flight_control; /* 闭环目标、PID 各项、状态及 rc.motor_us。 */

/* ANO F1 浮点通道：状态、等待剩余秒、反馈有效、总倾角、M1..M4(us)、故障锁存、校准样本数。 */
static volatile float s_control_diagnostics[10];
static void AppTaskControl(void *p_arg);
#endif

static OS_STK AppTaskSensorStk[APP_CFG_SENSOR_TASK_STK_SIZE];
static OS_STK APPTaskComStk[APP_CFG_COM_TASK_STK_SIZE];
// static OS_STK AppTaskDebugStk[APP_CFG_DEBUG_TASK_STK_SIZE];

static void BSP_Init(void);
static void AppTaskStart(void *p_arg);
static void AppTaskSensor(void *p_arg);
static void APPTaskCom(void *p_arg);
// static void AppTaskDebug(void *p_arg);
void SystemClock_Config(void);

void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    __HAL_RCC_PWR_CLK_ENABLE();
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE2);

    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    RCC_OscInitStruct.PLL.PLLM = 8;
    RCC_OscInitStruct.PLL.PLLN = 84;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ = 4;

    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
        Error_Handler();
    }

    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK |
                                  RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK) {
        Error_Handler();
    }
}

int main(void)
{
    INT8U err;

    HAL_Init();
    SystemClock_Config();

    OSInit();

    OSTaskCreate(AppTaskStart,
                 (void *)0,
                 &AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE - 1],
                 APP_CFG_STARTUP_TASK_PRIO);
    OSTaskNameSet(APP_CFG_STARTUP_TASK_PRIO, (INT8U *)(void *)"AppTaskStart", &err);

    OSStart();

    while (1) {
    }
}

static void BSP_Init(void)
{
    // OLED_Init();
#if ACCEL_CAL_MODE == 0
    BLDC_Init();
#endif
#if RC_RECEIVER_ENABLED
    IC_Init();
#endif
    ReadPeripherals_Init();
    UART1_FULL_INIT(115200); // must 115200 baudrate
}

static void AppTaskStart(void *p_arg)
{
#if ACCEL_CAL_MODE == 0
    INT8U err;
#endif

    (void)p_arg;

    OS_CPU_SysTickInitFreq(SystemCoreClock);
    BSP_Init();

    // /* 同时校准 TIM3 四路电调；必须全部拆桨，校准完成后注释此调用。 */
    // Calibrate_BLDC_All();

#if ACCEL_CAL_MODE == 0
    /* 四路保持最小油门脉宽，让电调完成上电解锁。 */
    BLDC_SetThrottle_us(BLDC_MIN_US, 1);
    BLDC_SetThrottle_us(BLDC_MIN_US, 2);
    BLDC_SetThrottle_us(BLDC_MIN_US, 3);
    BLDC_SetThrottle_us(BLDC_MIN_US, 4);
    OSTimeDlyHMSM(0, 0, 5, 0);

    if (OSTaskCreate(AppTaskControl, (void *)0,
                     &AppTaskControlStk[APP_CFG_CONTROL_TASK_STK_SIZE - 1],
                     APP_CFG_CONTROL_TASK_PRIO) != OS_ERR_NONE) {
        Error_Handler();
    }
    OSTaskNameSet(APP_CFG_CONTROL_TASK_PRIO, (INT8U *)(void *)"AppTaskControl", &err);
#endif

    OSTaskCreate(AppTaskSensor,
                 (void *)0,
                 &AppTaskSensorStk[APP_CFG_SENSOR_TASK_STK_SIZE - 1],
                 APP_CFG_SENSOR_TASK_PRIO);

    OSTaskCreate(APPTaskCom,
                (void *)0,
                 &APPTaskComStk[APP_CFG_COM_TASK_STK_SIZE - 1],
                 APP_CFG_COM_TASK_PRIO);

    // OSTaskCreate(AppTaskDebug,
    //              (void *)0,
    //              &AppTaskDebugStk[APP_CFG_DEBUG_TASK_STK_SIZE - 1],
    //              APP_CFG_DEBUG_TASK_PRIO);

    while (1) {
        OSTimeDlyHMSM(0, 0, 1, 0);
    }
}

#if ACCEL_CAL_MODE == 0

/// @brief 飞控任务入口，更新飞控状态并写入四路电机 PWM。
/// @details 初始化飞控后，每轮读取姿态和角速度反馈，遥控模式下同时读取接收机快照。
///          执行一次飞控更新，写入电机脉宽并保存诊断数据，再延时 FC_CONTROL_PERIOD_MS 毫秒。
/// @param[in] p_arg µC/OS-II 任务入口参数，创建任务时传入空指针。
static void AppTaskControl(void *p_arg)
{
#if RC_RECEIVER_ENABLED
    RC_Input_t input;
#endif
    FC_Feedback_t feedback;
    OS_CPU_SR cpu_sr;
    uint32_t now_ms;
#if !RC_RECEIVER_ENABLED
    uint32_t elapsed_ms;
#endif
    float wait_s;
    uint8_t i;
    (void)p_arg;
    if (!FC_Control_Init(&s_flight_control, SystemCoreClock) /*初始化飞控状态和横滚、俯仰、偏航三轴角速度 PID*/ ) {
        Error_Handler();
    }
    while (1) {
#if RC_RECEIVER_ENABLED
        IC_GetSnapshot(&input);
#endif
        ReadPeripherals_GetControlFeedback(&feedback); // 读取最近一次姿态解算结果和陀螺仪角速度，生成飞控反馈快照
        now_ms = HAL_GetTick();
#if RC_RECEIVER_ENABLED
        FC_Control_Update(&s_flight_control, &input, &feedback, now_ms); // 更新飞控状态，生成四路电机 PWM 脉宽
#else
        FC_Control_Update(&s_flight_control, 0, &feedback, now_ms); // 更新飞控状态，生成四路电机 PWM 脉宽
#endif
        for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
            BLDC_SetThrottle_us(s_flight_control.rc.motor_us[i], (uint8_t)(i + 1u)); // 写入四路电机 PWM 脉宽
        }
        wait_s = 0.0f;
#if !RC_RECEIVER_ENABLED
        /* 无故障锁存、尚未解锁且本次测试未结束时，计算供上位机显示的启动倒计时。 */
        if (!s_flight_control.bench_fault_latched && !s_flight_control.tipover_latched &&
            !s_flight_control.rc.armed && s_flight_control.rc.gesture != 2u) {
            /* gesture 为 0 表示尚未开始计时，此时已等待时间按 0 算。 */
            elapsed_ms = s_flight_control.rc.gesture == 0u ? 0u :
                         (uint32_t)(now_ms - s_flight_control.rc.gesture_start_ms);
            if (elapsed_ms < RC_BENCH_WAIT_MS) {
                wait_s = (float)(RC_BENCH_WAIT_MS - elapsed_ms) * 0.001f; /* 毫秒换算成秒。 */
            }
        }
#endif
        // 把这一轮飞控的状态和输出整理成一份诊断快照，供上位机监看
        OS_ENTER_CRITICAL();
        s_control_diagnostics[0] = (float)s_flight_control.status; /* 本轮飞控状态码（FC_Status_t） */
        s_control_diagnostics[1] = wait_s;                         /* 台架启动的剩余等待时间（秒） */
        s_control_diagnostics[2] = (float)feedback.valid;          /* 本轮收到的反馈有效标志（0 或 1） */
        s_control_diagnostics[3] = s_flight_control.tilt_deg;      /* 最近一次有效反馈计算出的机身总倾角（度） */
        for (i = 0u; i < RC_MOTOR_COUNT; ++i) {
            s_control_diagnostics[4u + i] = (float)s_flight_control.rc.motor_us[i];
        }
        s_control_diagnostics[8] = (float)(s_flight_control.bench_fault_latched ||
                                         s_flight_control.tipover_latched);
        s_control_diagnostics[9] = (float)g_MpuCalibrationCount;
        OS_EXIT_CRITICAL();


        OSTimeDlyHMSM(0, 0, 0, FC_CONTROL_PERIOD_MS);
    }
}
#endif

static void AppTaskSensor(void *p_arg)
{
    (void)p_arg;

    while (1) {
        ReadPeripherals_Process();
        OSTimeDlyHMSM(0, 0, 0, 1);
    }
}

static void APPTaskCom(void *p_arg)
{
#if ACCEL_CAL_MODE == 0
    uint32_t diagnostics_last_ms = 0u;
    float diagnostics[10];
    uint8_t i;
    OS_CPU_SR cpu_sr;
#endif
    (void)p_arg;

    while (1) {
        ReadPeripherals_Transmit();
#if ACCEL_CAL_MODE == 0
        if ((uint32_t)(HAL_GetTick() - diagnostics_last_ms) >= 200u) {
            diagnostics_last_ms = HAL_GetTick();
            OS_ENTER_CRITICAL();
            for (i = 0u; i < 10u; ++i) diagnostics[i] = s_control_diagnostics[i];
            OS_EXIT_CRITICAL();
            /* 沿用通信任务发送，避免多个任务同时写 UART。 */
            ANO_SendFloats(0xF1u, diagnostics, 10u);
        }
#endif
        OSTimeDlyHMSM(0, 0, 0, 5);
    }
}

// static void AppTaskDebug(void *p_arg)
// {
//     (void)p_arg;

//     while (1) {
//         OSTimeDlyHMSM(0, 0, 1, 0);
//     }
// }

void Error_Handler(void)
{
    __disable_irq();
    while (1) {
    }
}

