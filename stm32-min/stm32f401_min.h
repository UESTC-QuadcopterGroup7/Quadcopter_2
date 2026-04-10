#ifndef STM32F401_MIN_H
#define STM32F401_MIN_H

#include <stdint.h>

#define REG32(addr) (*(volatile uint32_t *)(addr))

#define PERIPH_BASE        0x40000000UL
#define AHB1PERIPH_BASE    (PERIPH_BASE + 0x00020000UL)
#define GPIOA_BASE         (AHB1PERIPH_BASE + 0x0000UL)
#define RCC_BASE           (AHB1PERIPH_BASE + 0x3800UL)

#define GPIOA_MODER        REG32(GPIOA_BASE + 0x00UL)
#define GPIOA_OTYPER       REG32(GPIOA_BASE + 0x04UL)
#define GPIOA_OSPEEDR      REG32(GPIOA_BASE + 0x08UL)
#define GPIOA_PUPDR        REG32(GPIOA_BASE + 0x0CUL)
#define GPIOA_ODR          REG32(GPIOA_BASE + 0x14UL)

#define RCC_AHB1ENR        REG32(RCC_BASE + 0x30UL)

#define RCC_AHB1ENR_GPIOAEN    (1UL << 0)

#define GPIO_MODER_MODE5_Pos   10U
#define GPIO_MODER_MODE5_Msk   (3UL << GPIO_MODER_MODE5_Pos)
#define GPIO_MODER_MODE5_OUT   (1UL << GPIO_MODER_MODE5_Pos)

#define GPIO_OTYPER_OT5        (1UL << 5)
#define GPIO_OSPEEDR_OSPEED5_Msk (3UL << 10)
#define GPIO_PUPDR_PUPD5_Msk   (3UL << 10)
#define GPIO_ODR_OD5           (1UL << 5)

#endif
