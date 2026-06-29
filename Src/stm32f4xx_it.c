#include "main.h"
#include "stm32f4xx_it.h"
#include "ucos_ii.h"

void NMI_Handler(void) {}
void HardFault_Handler(void) { while (1) {} }
void MemManage_Handler(void) { while (1) {} }
void BusFault_Handler(void) { while (1) {} }
void UsageFault_Handler(void) { while (1) {} }
void DebugMon_Handler(void) {}

void SysTick_Handler(void)
{
    HAL_IncTick();

    if (OSRunning == OS_TRUE) {
        OS_CPU_SysTickHandler();
    }
}

extern TIM_HandleTypeDef htim2;
void TIM2_IRQHandler(void)
{
    if (OSRunning == OS_TRUE) {
        OSIntEnter();
        HAL_TIM_IRQHandler(&htim2);
        OSIntExit();
    } else {
        HAL_TIM_IRQHandler(&htim2);
    }
}

extern TIM_HandleTypeDef htim4;
void TIM4_IRQHandler(void)
{
    if (OSRunning == OS_TRUE) {
        OSIntEnter();
        HAL_TIM_IRQHandler(&htim4);
        OSIntExit();
    } else {
        HAL_TIM_IRQHandler(&htim4);
    }
}
