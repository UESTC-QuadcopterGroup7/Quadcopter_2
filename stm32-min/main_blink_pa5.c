#include "stm32f401_min.h"

static void delay(volatile uint32_t cycles)
{
    while (cycles-- > 0U) {
        __asm volatile ("nop");
    }
}

int blink_pa5_main(void)
{
    RCC_AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    (void)RCC_AHB1ENR;

    GPIOA_MODER &= ~GPIO_MODER_MODE5_Msk;
    GPIOA_MODER |= GPIO_MODER_MODE5_OUT;

    GPIOA_OTYPER &= ~GPIO_OTYPER_OT5;
    GPIOA_OSPEEDR &= ~GPIO_OSPEEDR_OSPEED5_Msk;
    GPIOA_PUPDR &= ~GPIO_PUPDR_PUPD5_Msk;

    while (1) {
        GPIOA_ODR ^= GPIO_ODR_OD5;
        delay(400000U);
    }
}
