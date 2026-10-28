#include "main.h"

static TIM_HandleTypeDef htim5;
static uint8_t timer_initialized = 0;

/*
 * 微秒级延时。
 *
 * 旧实现每次调用都要 SET_COUNTER → HAL_TIM_Base_Start → 循环 → Stop，
 * 单次开销就接近 10us。而软件 I2C 的每个 SCL/SDA 边沿都要调一次，
 * 一条总线被压到十几 kHz，读一次 MPU6050 要十几毫秒——这是姿态延迟的主因。
 *
 * 现在：TIM5 只初始化一次并一直自由运行，延时只比较计数器差值，
 * 单次开销降到几百 ns，I2C 才能跑到百 kHz 量级。
 */
void Timer_Delay_us(uint16_t xus)
{
    uint32_t start;

    if (timer_initialized == 0) {
        __HAL_RCC_TIM5_CLK_ENABLE();

        htim5.Instance = TIM5;
        htim5.Init.Prescaler = 84 - 1;      /* 84 MHz / 84 = 1 MHz，1 计数 = 1 us */
        htim5.Init.Period = 0xFFFFFFFF;
        htim5.Init.CounterMode = TIM_COUNTERMODE_UP;
        htim5.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
        if (HAL_TIM_Base_Init(&htim5) != HAL_OK) {
            Error_Handler();
        }
        if (HAL_TIM_Base_Start(&htim5) != HAL_OK) {
            Error_Handler();
        }
        timer_initialized = 1;
    }

    start = __HAL_TIM_GET_COUNTER(&htim5);
    /* 计数器是 32 位自由运行，减法自然处理回绕 */
    while ((__HAL_TIM_GET_COUNTER(&htim5) - start) < (uint32_t)xus) {
    }
}
