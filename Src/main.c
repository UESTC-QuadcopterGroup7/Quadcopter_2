#include <string.h>
#include "main.h"
#include "ucos_ii.h"
#include "app_cfg.h"
#include "GPIO_Set.h"
#include "OLED.h"
#include "BLDC.h"
#include "Receive_IC.h"
#include "GY86.h"
#include "UART_Set.h"
#include "ReadPeripherals.h"

TIM_HandleTypeDef htim3;
UART_HandleTypeDef huart1;
uint16_t PWM_IN_Wid[4];

static OS_STK AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE];
static OS_STK AppTaskSensorStk[APP_CFG_SENSOR_TASK_STK_SIZE];
static OS_STK AppTaskDebugStk[APP_CFG_DEBUG_TASK_STK_SIZE];

static void BSP_Init(void);
static void AppTaskStart(void *p_arg);
static void AppTaskSensor(void *p_arg);
static void AppTaskDebug(void *p_arg);
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
    HAL_Init();
    SystemClock_Config();

    OSInit();

    OSTaskCreate(AppTaskStart,
                 (void *)0,
                 &AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE - 1],
                 APP_CFG_STARTUP_TASK_PRIO);

    OSStart();

    while (1) {
    }
}

static void BSP_Init(void)
{
    OLED_Init();
    IC_Init();
    BLDC_Init();
    ReadPeripherals_Init();
    UART1_FULL_INIT(9600);
}

static void AppTaskStart(void *p_arg)
{
    (void)p_arg;

    OS_CPU_SysTickInitFreq(SystemCoreClock);
    BSP_Init();

    OSTaskCreate(AppTaskSensor,
                 (void *)0,
                 &AppTaskSensorStk[APP_CFG_SENSOR_TASK_STK_SIZE - 1],
                 APP_CFG_SENSOR_TASK_PRIO);

    OSTaskCreate(AppTaskDebug,
                 (void *)0,
                 &AppTaskDebugStk[APP_CFG_DEBUG_TASK_STK_SIZE - 1],
                 APP_CFG_DEBUG_TASK_PRIO);

    while (1) {
        OSTimeDlyHMSM(0, 0, 1, 0);
    }
}

static void AppTaskSensor(void *p_arg)
{
    (void)p_arg;

    while (1) {
        ReadPeripherals_Process();
        OSTimeDlyHMSM(0, 0, 0, 5);
    }
}

static void AppTaskDebug(void *p_arg)
{
    (void)p_arg;

    while (1) {
        OSTimeDlyHMSM(0, 0, 1, 0);
    }
}

void Error_Handler(void)
{
    __disable_irq();
    while (1) {
    }
}


