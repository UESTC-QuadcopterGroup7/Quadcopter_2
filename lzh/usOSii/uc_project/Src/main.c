#include <string.h>
#include "main.h"
#include "ucos_ii.h"

#define  APP_TASK_START_STK_SIZE                    128u
#define  APP_TASK_START_PRIO                        2u

static  OS_STK  AppTaskStartStk[APP_TASK_START_STK_SIZE];

static  void  AppTaskStart (void *p_arg);

// HAL库时钟配置函数
void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /* 配置主电源电压范围 */
    __HAL_RCC_PWR_CLK_ENABLE();
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE2);

    /* ==================== 振荡器和PLL配置 ==================== */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON; // 使能HSI
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;         // 使能PLL
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI; // PLL时钟源：HSI
    RCC_OscInitStruct.PLL.PLLM = 8;                      // PLL分频系数M
    RCC_OscInitStruct.PLL.PLLN = 84;                     // PLL倍频系数N
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;          // PLL分频系数P
    RCC_OscInitStruct.PLL.PLLQ = 4;                      // PLL分频系数Q

    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }

    /* ==================== 系统时钟配置 ==================== */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK |
                                  RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK; // 系统时钟源：PLL
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;        // AHB不分频
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;         // APB1二分频
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;         // APB2不分频

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
    {
        Error_Handler();
    }
}


int main(void)
{
    HAL_Init();
    SystemClock_Config();
	
    OSInit();                                                   /* 初始化 uC/OS-II                                      */

    OSTaskCreate(AppTaskStart,                                  /* 创建起始任务                                         */
                 (void *)0,
                 &AppTaskStartStk[APP_TASK_START_STK_SIZE - 1],
                 APP_TASK_START_PRIO);

    OSStart();                                                  /* 开始多任务调度                                       */

    while (1)
    {

    }
}

static  void  AppTaskStart (void *p_arg)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    (void)p_arg;

    OS_CPU_SysTickInit(HAL_RCC_GetHCLKFreq() / OS_TICKS_PER_SEC); /* 初始化 SysTick                                     */

    /* 初始化 PA5 */
    __HAL_RCC_GPIOA_CLK_ENABLE();

    GPIO_InitStruct.Pin = GPIO_PIN_5;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    while (1) {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);                  /* 翻转 PA5                                             */
        OSTimeDly(500);
        // HAL_Delay(500);
        // OSTimeDlyHMSM(0, 0, 0, 500);                            /* 延时 500ms                                           */
    }
}


void Error_Handler(void)
{
    /* 用户可以在这里添加自己的实现来报告HAL错误返回状态 */
    __disable_irq();
    while (1)
    {
    }
}
