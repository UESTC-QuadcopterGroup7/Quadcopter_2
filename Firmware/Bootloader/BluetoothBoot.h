#ifndef BLUETOOTH_BOOT_H
#define BLUETOOTH_BOOT_H

#include <stdint.h>

#define QBT_APP_BASE       0x08004000u
#define QBT_STAGE_BASE     0x08040000u
#define QBT_FLASH_END      0x08080000u
#define QBT_REQUEST        0x51425431u

#define QBT_WAKE           "!QBT-UP!\n"
#define QBT_WAKE_LEN       (sizeof(QBT_WAKE) - 1u)

static inline uint8_t QBT_MatchWake(uint8_t byte, uint8_t *matched)
{
    if (byte == (uint8_t)QBT_WAKE[*matched]) {
        if (++*matched == QBT_WAKE_LEN) {
            *matched = 0u;
            return 1u;
        }
    } else {
        *matched = (uint8_t)(byte == (uint8_t)QBT_WAKE[0]);
    }
    return 0u;
}

/* 应用和引导程序共用 RTC 备份寄存器 0，复位后读取并清除。 */
static inline void QBT_EnableBackupWrite(void)
{
    uint32_t clock;

    RCC->APB1ENR |= RCC_APB1ENR_PWREN;
    (void)RCC->APB1ENR;
    PWR->CR |= PWR_CR_DBP;
    while ((PWR->CR & PWR_CR_DBP) == 0u) {}
    clock = RCC->BDCR & RCC_BDCR_RTCSEL;
    if (clock == 0u || clock == RCC_BDCR_RTCSEL_1) {
        RCC->CSR |= RCC_CSR_LSION;
        while ((RCC->CSR & RCC_CSR_LSIRDY) == 0u) {}
        RCC->BDCR |= RCC_BDCR_RTCSEL_1; /* LSI */
    }
    RCC->BDCR |= RCC_BDCR_RTCEN;
    (void)RCC->BDCR;
}

#endif
