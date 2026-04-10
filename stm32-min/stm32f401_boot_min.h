#ifndef STM32F401_BOOT_MIN_H
#define STM32F401_BOOT_MIN_H

#include <stdint.h>

#define REG32(addr) (*(volatile uint32_t *)(addr))

#define FLASH_BASE_ADDR         0x08000000UL
#define SRAM_BASE_ADDR          0x20000000UL
#define SRAM_SIZE_BYTES         (96UL * 1024UL)

#define PERIPH_BASE             0x40000000UL
#define AHB1PERIPH_BASE         (PERIPH_BASE + 0x00020000UL)

#define GPIOA_BASE              (AHB1PERIPH_BASE + 0x0000UL)
#define RCC_BASE                (AHB1PERIPH_BASE + 0x3800UL)
#define FLASH_IF_BASE           (AHB1PERIPH_BASE + 0x3C00UL)

#define GPIOA_MODER             REG32(GPIOA_BASE + 0x00UL)
#define GPIOA_OTYPER            REG32(GPIOA_BASE + 0x04UL)
#define GPIOA_OSPEEDR           REG32(GPIOA_BASE + 0x08UL)
#define GPIOA_PUPDR             REG32(GPIOA_BASE + 0x0CUL)
#define GPIOA_BSRR              REG32(GPIOA_BASE + 0x18UL)

#define RCC_AHB1ENR             REG32(RCC_BASE + 0x30UL)

#define FLASH_KEYR              REG32(FLASH_IF_BASE + 0x04UL)
#define FLASH_SR                REG32(FLASH_IF_BASE + 0x0CUL)
#define FLASH_CR                REG32(FLASH_IF_BASE + 0x10UL)

#define SCB_VTOR                REG32(0xE000ED08UL)

#define RCC_AHB1ENR_GPIOAEN     (1UL << 0)

#define GPIO_MODER_MODE5_Pos    10U
#define GPIO_MODER_MODE5_Msk    (3UL << GPIO_MODER_MODE5_Pos)
#define GPIO_MODER_MODE5_OUT    (1UL << GPIO_MODER_MODE5_Pos)

#define GPIO_OTYPER_OT5         (1UL << 5)
#define GPIO_OSPEEDR_OSPEED5_Msk (3UL << 10)
#define GPIO_PUPDR_PUPD5_Msk    (3UL << 10)
#define GPIO_BSRR_BS5           (1UL << 5)
#define GPIO_BSRR_BR5           (1UL << 21)

#define FLASH_KEY1              0x45670123UL
#define FLASH_KEY2              0xCDEF89ABUL

#define FLASH_SR_EOP            (1UL << 0)
#define FLASH_SR_OPERR          (1UL << 1)
#define FLASH_SR_WRPERR         (1UL << 4)
#define FLASH_SR_PGAERR         (1UL << 5)
#define FLASH_SR_PGPERR         (1UL << 6)
#define FLASH_SR_PGSERR         (1UL << 7)
#define FLASH_SR_BSY            (1UL << 16)

#define FLASH_SR_ERROR_MASK \
    (FLASH_SR_OPERR | FLASH_SR_WRPERR | FLASH_SR_PGAERR | FLASH_SR_PGPERR | FLASH_SR_PGSERR)

#define FLASH_CR_PG             (1UL << 0)
#define FLASH_CR_SER            (1UL << 1)
#define FLASH_CR_SNB_Pos        3U
#define FLASH_CR_SNB_Msk        (0xFUL << FLASH_CR_SNB_Pos)
#define FLASH_CR_PSIZE_Pos      8U
#define FLASH_CR_PSIZE_Msk      (3UL << FLASH_CR_PSIZE_Pos)
#define FLASH_CR_PSIZE_X32      (2UL << FLASH_CR_PSIZE_Pos)
#define FLASH_CR_STRT           (1UL << 16)
#define FLASH_CR_LOCK           (1UL << 31)

#endif
