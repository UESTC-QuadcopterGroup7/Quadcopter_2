#include "main.h"
#include "Receive_IC.h"

TIM_HandleTypeDef htim2;
TIM_HandleTypeDef htim4;
volatile uint16_t PWM_IN_Wid[RC_CHANNEL_COUNT];

static uint8_t s_capture_high[RC_CHANNEL_COUNT];
static uint32_t s_rising_count[RC_CHANNEL_COUNT];
static uint32_t s_rising_ms[RC_CHANNEL_COUNT];
static volatile uint32_t s_updated_ms[RC_CHANNEL_COUNT];
static volatile uint8_t s_valid_mask;

void IC_Init(void)
{
    GPIO_InitTypeDef gpio = {0};
    TIM_IC_InitTypeDef capture = {0};
    uint8_t i;

    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        PWM_IN_Wid[i] = 0u;
        s_capture_high[i] = 0u;
        s_rising_count[i] = 0u;
        s_rising_ms[i] = 0u;
        s_updated_ms[i] = 0u;
    }
    s_valid_mask = 0u;
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();
    __HAL_RCC_TIM2_CLK_ENABLE();
    __HAL_RCC_TIM4_CLK_ENABLE();

    gpio.Pin = IC_PIN_CH1 | IC_PIN_CH2;
    gpio.Mode = GPIO_MODE_AF_PP;
    gpio.Speed = GPIO_SPEED_FREQ_HIGH;
    gpio.Pull = GPIO_PULLUP;
    gpio.Alternate = GPIO_AF1_TIM2;
    HAL_GPIO_Init(IC_PORT_A, &gpio);
    gpio.Pin = IC_PIN_CH3;
    HAL_GPIO_Init(IC_PORT_B, &gpio);
    gpio.Pin = IC_PIN_CH4;
    gpio.Alternate = GPIO_AF2_TIM4;
    HAL_GPIO_Init(IC_PORT_B, &gpio);

    htim2.Instance = TIM2;
    htim2.Init.Prescaler = 84u - 1u;
    htim2.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
    htim2.Init.CounterMode = TIM_COUNTERMODE_UP;
    htim2.Init.Period = 0xFFFFFFFFu; /* TIM2 为 32 位。 */
    htim4.Instance = TIM4;
    htim4.Init.Prescaler = 84u - 1u;
    htim4.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
    htim4.Init.CounterMode = TIM_COUNTERMODE_UP;
    htim4.Init.Period = 0xFFFFu;     /* TIM4 为 16 位。 */
    if (HAL_TIM_Base_Init(&htim2) != HAL_OK || HAL_TIM_IC_Init(&htim2) != HAL_OK ||
        HAL_TIM_Base_Init(&htim4) != HAL_OK || HAL_TIM_IC_Init(&htim4) != HAL_OK) {
        Error_Handler();
        return;
    }

    capture.ICFilter = 0x04u;
    capture.ICPolarity = TIM_ICPOLARITY_RISING;
    capture.ICPrescaler = TIM_ICPSC_DIV1;
    capture.ICSelection = TIM_ICSELECTION_DIRECTTI;
    if (HAL_TIM_IC_ConfigChannel(&htim2, &capture, TIM_CHANNEL_1) != HAL_OK ||
        HAL_TIM_IC_ConfigChannel(&htim2, &capture, TIM_CHANNEL_2) != HAL_OK ||
        HAL_TIM_IC_ConfigChannel(&htim2, &capture, TIM_CHANNEL_3) != HAL_OK ||
        HAL_TIM_IC_ConfigChannel(&htim4, &capture, TIM_CHANNEL_2) != HAL_OK) {
        Error_Handler();
        return;
    }

    HAL_NVIC_SetPriority(TIM2_IRQn, 2u, 0u);
    HAL_NVIC_EnableIRQ(TIM2_IRQn);
    HAL_NVIC_SetPriority(TIM4_IRQn, 2u, 0u);
    HAL_NVIC_EnableIRQ(TIM4_IRQn);
    if (HAL_TIM_IC_Start_IT(&htim2, TIM_CHANNEL_1) != HAL_OK ||
        HAL_TIM_IC_Start_IT(&htim2, TIM_CHANNEL_2) != HAL_OK ||
        HAL_TIM_IC_Start_IT(&htim2, TIM_CHANNEL_3) != HAL_OK ||
        HAL_TIM_IC_Start_IT(&htim4, TIM_CHANNEL_2) != HAL_OK) {
        Error_Handler();
    }
}

void IC_GetSnapshot(RC_Input_t *input)
{
    uint32_t primask;
    uint8_t i;
    if (input == 0) return;
    /* PRIMASK 同时屏蔽 TIM2/TIM4；保持调用前的中断状态。 */
    primask = __get_PRIMASK();
    __disable_irq();
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        input->pulse_us[i] = PWM_IN_Wid[i];
        input->updated_ms[i] = s_updated_ms[i];
    }
    input->valid_mask = s_valid_mask;
    __set_PRIMASK(primask);
}

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
    uint32_t channel, overcapture_flag, count, now_ms, width;
    uint8_t idx;
    if (htim->Instance == TIM2 && htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1) {
        channel = TIM_CHANNEL_1;
        overcapture_flag = TIM_FLAG_CC1OF;
        idx = 0u;
    } else if (htim->Instance == TIM2 && htim->Channel == HAL_TIM_ACTIVE_CHANNEL_2) {
        channel = TIM_CHANNEL_2;
        overcapture_flag = TIM_FLAG_CC2OF;
        idx = 1u;
    } else if (htim->Instance == TIM2 && htim->Channel == HAL_TIM_ACTIVE_CHANNEL_3) {
        channel = TIM_CHANNEL_3;
        overcapture_flag = TIM_FLAG_CC3OF;
        idx = 2u;
    } else if (htim->Instance == TIM4 && htim->Channel == HAL_TIM_ACTIVE_CHANNEL_2) {
        channel = TIM_CHANNEL_2;
        overcapture_flag = TIM_FLAG_CC2OF;
        idx = 3u;
    } else {
        return;
    }

    if (__HAL_TIM_GET_FLAG(htim, overcapture_flag) != RESET) {
        __HAL_TIM_CLEAR_FLAG(htim, overcapture_flag);
        s_capture_high[idx] = 0u;
        s_valid_mask &= (uint8_t)~(1u << idx);
        __HAL_TIM_SET_CAPTUREPOLARITY(htim, channel, TIM_ICPOLARITY_RISING);
        return;
    }
    count = HAL_TIM_ReadCapturedValue(htim, channel);
    now_ms = HAL_GetTick();
    if (s_capture_high[idx] == 0u) {
        s_rising_count[idx] = count;
        s_rising_ms[idx] = now_ms;
        s_capture_high[idx] = 1u;
        __HAL_TIM_SET_CAPTUREPOLARITY(htim, channel, TIM_ICPOLARITY_FALLING);
        return;
    }

    s_capture_high[idx] = 0u;
    width = (uint32_t)(count - s_rising_count[idx]);
    if (htim->Instance == TIM4) {
        width &= 0xFFFFu; /* 16 位计数器按 65536 回绕，不能当作 32 位处理。 */
    }
    PWM_IN_Wid[idx] = (width <= 0xFFFFu) ? (uint16_t)width : 0u;
    /* 毫秒时间检查拒绝长高电平在 TIM4 多次回绕后伪装成合法脉宽。 */
    if (width >= RC_VALID_MIN_US && width <= RC_VALID_MAX_US &&
        (uint32_t)(now_ms - s_rising_ms[idx]) <= (RC_VALID_MAX_US / 1000u + 1u)) {
        s_updated_ms[idx] = now_ms;
        s_valid_mask |= (uint8_t)(1u << idx);
    } else {
        s_valid_mask &= (uint8_t)~(1u << idx);
    }
    /* 只改极性，不停启整个定时器，不在中断内写任何电机输出。 */
    __HAL_TIM_SET_CAPTUREPOLARITY(htim, channel, TIM_ICPOLARITY_RISING);
}
