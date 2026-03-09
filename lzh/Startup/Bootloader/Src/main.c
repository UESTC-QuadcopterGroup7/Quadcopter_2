#include "stm32f4xx_hal.h"
#include <string.h>

// -------------------------------------------------------------------------
// 配置区域
// -------------------------------------------------------------------------

// 应用程序起始地址
// Bootloader 占用 Sector 0 (0x08000000 - 0x08003FFF, 16KB)
// App 从 Sector 1 (0x08004000) 开始
#define APP_ADDRESS     (0x08004000)

// 指示灯 (根据你的板子修改)
#define LED_GPIO        GPIOA
#define LED_PIN         GPIO_PIN_5

// -------------------------------------------------------------------------

typedef void (*pFunction)(void);

void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void Error_Handler(void);

// -------------------------------------------------------------------------
// Bootloader 核心功能函数
// -------------------------------------------------------------------------

// 跳转到应用程序 (Flash 运行模式)
void JumpToApplication(void)
{
    uint32_t JumpAddress;
    pFunction JumpToApplicationFn;

    // 1. 检查栈顶地址是否合法
    // STM32F401RE SRAM 范围: 0x20000000 - 0x20017FFF (96KB)
    // 检查 App 的第一个字 (MSP) 是否在 SRAM 范围内
    if (((*(__IO uint32_t*)APP_ADDRESS) & 0x2FF00000) == 0x20000000)
    {
        // 2. 关闭所有中断
        __disable_irq();
        
        // 3. 关闭外设时钟 / DeInit 外设
        HAL_RCC_DeInit();
        HAL_DeInit();
        
        // 关闭 SysTick
        SysTick->CTRL = 0;
        SysTick->LOAD = 0;
        SysTick->VAL = 0;

        // 4. 获取 App 的复位中断处理函数地址 (Reset Handler)
        // 向量表第 2 个字 (Offset + 4) 是 Reset Handler
        JumpAddress = *(__IO uint32_t*)(APP_ADDRESS + 4);
        JumpToApplicationFn = (pFunction)JumpAddress;

        // 5. 设置主堆栈指针 (MSP)
        __set_MSP(*(__IO uint32_t*)APP_ADDRESS);

        // 6. 跳转执行 App
        JumpToApplicationFn();
    }
    else
    {
        // App 地址无效，闪烁 LED 报错
        while (1)
        {
            HAL_GPIO_TogglePin(LED_GPIO, LED_PIN);
            HAL_Delay(100);
        }
    }
}

// -------------------------------------------------------------------------

int main(void)
{
    // 1. 系统初始化
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();

    // 2. 简单的 LED 指示，表示 Bootloader 启动
    HAL_GPIO_WritePin(LED_GPIO, LED_PIN, GPIO_PIN_SET);
    HAL_Delay(200);
    HAL_GPIO_WritePin(LED_GPIO, LED_PIN, GPIO_PIN_RESET);
    HAL_Delay(200);

    // 3. 执行 Bootloader 流程
    // 在标准 Flash 运行模式下，Bootloader 不需要拷贝代码或初始化 App 的变量。
    // App 的启动文件 (Startup code) 会自动处理 .data 和 .bss 的初始化。
    // Bootloader 只需负责校验和跳转。

    JumpToApplication();

    while (1)
    {
        // Should not reach here
    }
}

// -------------------------------------------------------------------------
// 硬件初始化函数
// -------------------------------------------------------------------------

void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Configure the main internal regulator output voltage
    */
    __HAL_RCC_PWR_CLK_ENABLE();
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE2);

    /** Initializes the RCC Oscillators according to the specified parameters
    * in the RCC_OscInitTypeDef structure.
    */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    RCC_OscInitStruct.PLL.PLLM = 16;
    RCC_OscInitStruct.PLL.PLLN = 336;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV4;
    RCC_OscInitStruct.PLL.PLLQ = 7;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
    */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                                |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
    {
        Error_Handler();
    }
}

static void MX_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOH_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();

    /*Configure GPIO pin Output Level */
    HAL_GPIO_WritePin(LED_GPIO, LED_PIN, GPIO_PIN_RESET);

    /*Configure GPIO pin : LED_PIN */
    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(LED_GPIO, &GPIO_InitStruct);
}

void Error_Handler(void)
{
    while(1)
    {
        // 错误处理: 闪烁 LED
        HAL_GPIO_TogglePin(LED_GPIO, LED_PIN);
        HAL_Delay(100);
    }
}
