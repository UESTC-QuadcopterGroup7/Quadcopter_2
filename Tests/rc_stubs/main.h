#ifndef RC_TEST_MAIN_H
#define RC_TEST_MAIN_H

#include <stdint.h>

typedef struct {
    uint32_t captured[4];
    uint32_t polarity[4];
    uint32_t flags;
} TIM_TypeDef;
typedef struct {
    uint32_t Prescaler, ClockDivision, CounterMode, Period;
} TIM_Base_InitTypeDef;
typedef struct {
    TIM_TypeDef *Instance;
    TIM_Base_InitTypeDef Init;
    uint32_t Channel;
} TIM_HandleTypeDef;
typedef struct {
    uint32_t Pin, Mode, Speed, Pull, Alternate;
} GPIO_InitTypeDef;
typedef struct {
    uint32_t ICFilter, ICPolarity, ICPrescaler, ICSelection;
} TIM_IC_InitTypeDef;

extern TIM_TypeDef rc_test_tim2, rc_test_tim4;
extern uint32_t rc_test_primask;
#define TIM2 (&rc_test_tim2)
#define TIM4 (&rc_test_tim4)
#define GPIOA 0u
#define GPIOB 1u
#define GPIO_PIN_0 (1u << 0)
#define GPIO_PIN_1 (1u << 1)
#define GPIO_PIN_7 (1u << 7)
#define GPIO_PIN_10 (1u << 10)
#define GPIO_MODE_AF_PP 2u
#define GPIO_SPEED_FREQ_HIGH 3u
#define GPIO_PULLUP 1u
#define GPIO_AF1_TIM2 1u
#define GPIO_AF2_TIM4 2u
#define TIM_CLOCKDIVISION_DIV1 0u
#define TIM_COUNTERMODE_UP 0u
#define TIM_ICPSC_DIV1 0u
#define TIM_ICSELECTION_DIRECTTI 1u
#define TIM_ICPOLARITY_RISING 0u
#define TIM_ICPOLARITY_FALLING 2u
#define TIM_CHANNEL_1 0u
#define TIM_CHANNEL_2 4u
#define TIM_CHANNEL_3 8u
#define TIM_CHANNEL_4 12u
#define HAL_TIM_ACTIVE_CHANNEL_1 1u
#define HAL_TIM_ACTIVE_CHANNEL_2 2u
#define HAL_TIM_ACTIVE_CHANNEL_3 4u
#define HAL_TIM_ACTIVE_CHANNEL_4 8u
#define TIM_FLAG_CC1OF 0x0200u
#define TIM_FLAG_CC2OF 0x0400u
#define TIM_FLAG_CC3OF 0x0800u
#define TIM2_IRQn 28u
#define TIM4_IRQn 30u
#define HAL_OK 0
#define RESET 0u
#define __HAL_RCC_GPIOA_CLK_ENABLE() ((void)0)
#define __HAL_RCC_GPIOB_CLK_ENABLE() ((void)0)
#define __HAL_RCC_TIM2_CLK_ENABLE() ((void)0)
#define __HAL_RCC_TIM4_CLK_ENABLE() ((void)0)
#define __HAL_TIM_GET_FLAG(h, f) (((h)->Instance->flags & (f)) != 0u)
#define __HAL_TIM_CLEAR_FLAG(h, f) ((h)->Instance->flags &= ~(f))
#define __HAL_TIM_SET_CAPTUREPOLARITY(h, c, p) ((h)->Instance->polarity[(c) / 4u] = (p))
#define __get_PRIMASK() rc_test_primask
#define __disable_irq() (rc_test_primask = 1u)
#define __set_PRIMASK(p) (rc_test_primask = (p))

void HAL_GPIO_Init(unsigned port, GPIO_InitTypeDef *gpio);
int HAL_TIM_Base_Init(TIM_HandleTypeDef *timer);
int HAL_TIM_IC_Init(TIM_HandleTypeDef *timer);
int HAL_TIM_IC_ConfigChannel(TIM_HandleTypeDef *timer, TIM_IC_InitTypeDef *config, uint32_t channel);
int HAL_TIM_IC_Start_IT(TIM_HandleTypeDef *timer, uint32_t channel);
void HAL_NVIC_SetPriority(unsigned irq, unsigned priority, unsigned subpriority);
void HAL_NVIC_EnableIRQ(unsigned irq);
uint32_t HAL_TIM_ReadCapturedValue(TIM_HandleTypeDef *timer, uint32_t channel);
uint32_t HAL_GetTick(void);
void Error_Handler(void);
void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *timer);

#endif
