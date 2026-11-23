#ifndef __RECEIVE_IC_H
#define __RECEIVE_IC_H

#include "RC_Control.h"

// TIM2 CH1 -> PA0
// TIM2 CH2 -> PA1
// TIM2 CH3 -> PB10
// TIM4 CH2 -> PB7

#define IC_PORT_A GPIOA
#define IC_PORT_B GPIOB

#define IC_PIN_CH1 GPIO_PIN_0
#define IC_PIN_CH2 GPIO_PIN_1
#define IC_PIN_CH3 GPIO_PIN_10
#define IC_PIN_CH4 GPIO_PIN_7

void IC_Init(void);
/* 中断只写接收数据；电机由控制任务统一更新。 */
extern volatile uint16_t PWM_IN_Wid[RC_CHANNEL_COUNT];
void IC_GetSnapshot(RC_Input_t *input);

#endif

