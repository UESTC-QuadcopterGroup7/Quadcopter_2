#ifndef HOST_SWD_STM32F4_FLASH_H
#define HOST_SWD_STM32F4_FLASH_H

#include <stddef.h>
#include <stdint.h>

#include "adiv5.h"

int stm32f4_flash_unlock(adiv5_dp_t *dp);
int stm32f4_flash_lock(adiv5_dp_t *dp);
int stm32f4_flash_erase(adiv5_dp_t *dp, uint32_t address, uint32_t length);
int stm32f4_flash_program(adiv5_dp_t *dp, uint32_t address, const uint8_t *data, size_t length);
int stm32f4_flash_verify(adiv5_dp_t *dp, uint32_t address, const uint8_t *data, size_t length);

#endif
