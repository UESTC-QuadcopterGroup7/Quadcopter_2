#include "stm32f4xx_hal.h"

// -------------------------------------------------------------------------
// 配置区域
// -------------------------------------------------------------------------

// 应用程序起始地址
// Bootloader 占用 Sector 0 (0x08000000 - 0x08003FFF, 16KB)
// App 从 Sector 1 (0x08004000) 开始
#define APP_ADDRESS     (0x08004000)

// 触发 Bootloader 模式的按键 (根据你的板子修改)
// 假设是 PC13 (Nucleo 板载用户按键)
#define BOOT_KEY_GPIO   GPIOC
#define BOOT_KEY_PIN    GPIO_PIN_13
#define BOOT_KEY_STATE  GPIO_PIN_RESET  // 按下为低电平

// 指示灯 (根据你的板子修改)
// 假设是 PA5 (Nucleo 板载 LED)
#define LED_GPIO        GPIOA
#define LED_PIN         GPIO_PIN_5

// -------------------------------------------------------------------------

typedef void (*pFunction)(void);

void SystemClock_Config(void);
static void MX_GPIO_Init(void);

/**
 * @brief  跳转到应用程序
 */
void JumpToApplication(void)
{
    uint32_t JumpAddress;
    pFunction JumpToApplicationFn;

    // 1. 检查栈顶地址是否合法
    // APP_ADDRESS 处存放的是 MSP 的初始值。
    // STM32F401RE 的 SRAM 范围是 0x20000000 到 0x20018000 (96KB)
    // 简单的检查方法是看是否以 0x2000xxxx 开头
    if (((*(__IO uint32_t*)APP_ADDRESS) & 0x2FF00000) == 0x20000000)
    {
        // 2. 关闭所有中断
        // 在跳转前必须关闭所有中断，防止跳转过程中发生中断导致 HardFault
        // App 启动后会在 SystemInit 或 main 中重新开启中断
        __disable_irq();

        // 3. 获取 App 的复位中断处理函数地址
        // 向量表的第 2 个字 (偏移 +4) 是 Reset_Handler 的地址
        JumpAddress = *(__IO uint32_t*)(APP_ADDRESS + 4);
        JumpToApplicationFn = (pFunction)JumpAddress;

        // 4. 设置主堆栈指针 (MSP)
        // 使用 App 向量表中定义的栈顶地址
        __set_MSP(*(__IO uint32_t*)APP_ADDRESS);

        // 5. 跳转执行 App
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

int main(void)
{
    // 初始化 HAL 库
    HAL_Init();

    // 配置系统时钟
    SystemClock_Config();

    // 初始化 GPIO (按键和 LED)
    MX_GPIO_Init();

    // 检查是否按下按键进入 Bootloader 模式
    // 如果上电时按住按键，则停留在 Bootloader (例如等待串口下载)
    if (HAL_GPIO_ReadPin(BOOT_KEY_GPIO, BOOT_KEY_PIN) == BOOT_KEY_STATE)
    {
        // 进入 Bootloader 维护模式
        // 这里可以添加串口 IAP (In-Application Programming) 代码
        // 目前仅做 LED 慢闪示意
        while (1)
        {
            HAL_GPIO_TogglePin(LED_GPIO, LED_PIN);
            HAL_Delay(500); // 慢闪
        }
    }

    // 否则，直接尝试跳转到 App
    JumpToApplication();

    while (1)
    {
        // 理论上不会运行到这里
    }
}

/**
 * @brief System Clock Configuration
 * @retval None
 */
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
        while(1);
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
        while(1);
    }
}

/**
 * @brief GPIO Initialization Function
 * @param None
 * @retval None
 */
static void MX_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOH_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();

    /*Configure GPIO pin Output Level */
    HAL_GPIO_WritePin(LED_GPIO, LED_PIN, GPIO_PIN_RESET);

    /*Configure GPIO pin : BOOT_KEY_PIN */
    GPIO_InitStruct.Pin = BOOT_KEY_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
    GPIO_InitStruct.Pull = GPIO_PULLUP;
    HAL_GPIO_Init(BOOT_KEY_GPIO, &GPIO_InitStruct);

    /*Configure GPIO pin : LED_PIN */
    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(LED_GPIO, &GPIO_InitStruct);
}
