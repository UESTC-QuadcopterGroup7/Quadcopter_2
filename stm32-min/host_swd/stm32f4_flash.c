#include <stddef.h>
#include <stdint.h>

#include "stm32f4_flash.h"
#include "swd_status.h"

#define STM32F4_FLASH_KEYR   0x40023C04UL
#define STM32F4_FLASH_SR     0x40023C0CUL
#define STM32F4_FLASH_CR     0x40023C10UL

#define STM32F4_FLASH_KEY1   0x45670123UL
#define STM32F4_FLASH_KEY2   0xCDEF89ABUL

#define STM32F4_FLASH_SR_EOP     (1UL << 0)
#define STM32F4_FLASH_SR_OPERR   (1UL << 1)
#define STM32F4_FLASH_SR_WRPERR  (1UL << 4)
#define STM32F4_FLASH_SR_PGAERR  (1UL << 5)
#define STM32F4_FLASH_SR_PGPERR  (1UL << 6)
#define STM32F4_FLASH_SR_PGSERR  (1UL << 7)
#define STM32F4_FLASH_SR_BSY     (1UL << 16)

#define STM32F4_FLASH_SR_ERROR_MASK \
    (STM32F4_FLASH_SR_OPERR | STM32F4_FLASH_SR_WRPERR | STM32F4_FLASH_SR_PGAERR | \
     STM32F4_FLASH_SR_PGPERR | STM32F4_FLASH_SR_PGSERR)

#define STM32F4_FLASH_CR_PG          (1UL << 0)
#define STM32F4_FLASH_CR_SER         (1UL << 1)
#define STM32F4_FLASH_CR_SNB_Pos     3U
#define STM32F4_FLASH_CR_SNB_Msk     (0xFUL << STM32F4_FLASH_CR_SNB_Pos)
#define STM32F4_FLASH_CR_PSIZE_Pos   8U
#define STM32F4_FLASH_CR_PSIZE_Msk   (3UL << STM32F4_FLASH_CR_PSIZE_Pos)
#define STM32F4_FLASH_CR_PSIZE_X32   (2UL << STM32F4_FLASH_CR_PSIZE_Pos)
#define STM32F4_FLASH_CR_STRT        (1UL << 16)
#define STM32F4_FLASH_CR_LOCK        (1UL << 31)

typedef struct
{
    uint32_t sector;
    uint32_t start;
    uint32_t size;
} flash_sector_t;

static const flash_sector_t g_sectors[] = {
    {0U, 0x08000000UL, 16UL * 1024UL},
    {1U, 0x08004000UL, 16UL * 1024UL},
    {2U, 0x08008000UL, 16UL * 1024UL},
    {3U, 0x0800C000UL, 16UL * 1024UL},
    {4U, 0x08010000UL, 64UL * 1024UL},
    {5U, 0x08020000UL, 128UL * 1024UL},
    {6U, 0x08040000UL, 128UL * 1024UL},
    {7U, 0x08060000UL, 128UL * 1024UL}
};

static int flash_wait_ready(adiv5_dp_t *dp)
{
    uint32_t status = 0U;
    unsigned int attempt;
    int rc;

    for (attempt = 0U; attempt < 200000U; ++attempt) {
        rc = adiv5_mem_read32(dp, STM32F4_FLASH_SR, &status);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        if ((status & STM32F4_FLASH_SR_BSY) == 0U) {
            break;
        }
    }

    if ((status & STM32F4_FLASH_SR_BSY) != 0U) {
        return SWD_STATUS_TARGET;
    }

    rc = adiv5_mem_write32(dp,
                           STM32F4_FLASH_SR,
                           status & (STM32F4_FLASH_SR_EOP | STM32F4_FLASH_SR_ERROR_MASK));
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return (status & STM32F4_FLASH_SR_ERROR_MASK) == 0U ? SWD_STATUS_OK : SWD_STATUS_TARGET;
}

static int flash_sector_from_address(uint32_t address, uint32_t *sector_index)
{
    size_t index;

    if (sector_index == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    for (index = 0U; index < (sizeof(g_sectors) / sizeof(g_sectors[0])); ++index) {
        if ((address >= g_sectors[index].start) &&
            (address < (g_sectors[index].start + g_sectors[index].size))) {
            *sector_index = (uint32_t)index;
            return SWD_STATUS_OK;
        }
    }

    return SWD_STATUS_ARGUMENT;
}

static int flash_erase_sector(adiv5_dp_t *dp, uint32_t sector_number)
{
    uint32_t control = 0U;
    int rc;

    rc = flash_wait_ready(dp);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_mem_read32(dp, STM32F4_FLASH_CR, &control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    control &= ~(STM32F4_FLASH_CR_PG | STM32F4_FLASH_CR_SER |
                 STM32F4_FLASH_CR_SNB_Msk | STM32F4_FLASH_CR_PSIZE_Msk);
    control |= STM32F4_FLASH_CR_SER |
               STM32F4_FLASH_CR_PSIZE_X32 |
               (sector_number << STM32F4_FLASH_CR_SNB_Pos);

    rc = adiv5_mem_write32(dp, STM32F4_FLASH_CR, control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_mem_write32(dp, STM32F4_FLASH_CR, control | STM32F4_FLASH_CR_STRT);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = flash_wait_ready(dp);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    control &= ~(STM32F4_FLASH_CR_SER | STM32F4_FLASH_CR_SNB_Msk | STM32F4_FLASH_CR_PSIZE_Msk);
    return adiv5_mem_write32(dp, STM32F4_FLASH_CR, control);
}

static uint32_t pack_word(const uint8_t *data, size_t length)
{
    uint32_t value = 0xFFFFFFFFUL;
    size_t index;

    for (index = 0U; index < 4U; ++index) {
        uint32_t byte_value = 0xFFU;

        if (index < length) {
            byte_value = data[index];
        }

        value &= ~(0xFFUL << (index * 8U));
        value |= byte_value << (index * 8U);
    }

    return value;
}

int stm32f4_flash_unlock(adiv5_dp_t *dp)
{
    uint32_t control = 0U;
    int rc;

    rc = adiv5_mem_read32(dp, STM32F4_FLASH_CR, &control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    if ((control & STM32F4_FLASH_CR_LOCK) == 0U) {
        return SWD_STATUS_OK;
    }

    rc = adiv5_mem_write32(dp, STM32F4_FLASH_KEYR, STM32F4_FLASH_KEY1);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_mem_write32(dp, STM32F4_FLASH_KEYR, STM32F4_FLASH_KEY2);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_mem_read32(dp, STM32F4_FLASH_CR, &control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return (control & STM32F4_FLASH_CR_LOCK) == 0U ? SWD_STATUS_OK : SWD_STATUS_TARGET;
}

int stm32f4_flash_lock(adiv5_dp_t *dp)
{
    uint32_t control = 0U;
    int rc;

    rc = adiv5_mem_read32(dp, STM32F4_FLASH_CR, &control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return adiv5_mem_write32(dp, STM32F4_FLASH_CR, control | STM32F4_FLASH_CR_LOCK);
}

int stm32f4_flash_erase(adiv5_dp_t *dp, uint32_t address, uint32_t length)
{
    uint32_t first_sector_index = 0U;
    uint32_t last_sector_index = 0U;
    uint32_t end_address;
    uint32_t sector_index;
    int rc;

    if ((dp == NULL) || (length == 0U)) {
        return SWD_STATUS_ARGUMENT;
    }

    end_address = address + length - 1U;

    rc = flash_sector_from_address(address, &first_sector_index);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = flash_sector_from_address(end_address, &last_sector_index);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    for (sector_index = first_sector_index; sector_index <= last_sector_index; ++sector_index) {
        rc = flash_erase_sector(dp, g_sectors[sector_index].sector);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }
    }

    return SWD_STATUS_OK;
}

int stm32f4_flash_program(adiv5_dp_t *dp, uint32_t address, const uint8_t *data, size_t length)
{
    uint32_t control = 0U;
    uint32_t word;
    size_t offset;
    size_t chunk;
    int rc;

    if ((dp == NULL) || ((data == NULL) && (length != 0U))) {
        return SWD_STATUS_ARGUMENT;
    }

    rc = adiv5_mem_read32(dp, STM32F4_FLASH_CR, &control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    control &= ~(STM32F4_FLASH_CR_SER | STM32F4_FLASH_CR_SNB_Msk | STM32F4_FLASH_CR_PSIZE_Msk);
    control |= STM32F4_FLASH_CR_PG | STM32F4_FLASH_CR_PSIZE_X32;
    rc = adiv5_mem_write32(dp, STM32F4_FLASH_CR, control);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    for (offset = 0U; offset < length; offset += 4U) {
        chunk = length - offset;
        if (chunk > 4U) {
            chunk = 4U;
        }

        word = pack_word(data + offset, chunk);
        rc = adiv5_mem_write32(dp, address + (uint32_t)offset, word);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        rc = flash_wait_ready(dp);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }
    }

    control &= ~(STM32F4_FLASH_CR_PG | STM32F4_FLASH_CR_PSIZE_Msk);
    return adiv5_mem_write32(dp, STM32F4_FLASH_CR, control);
}

int stm32f4_flash_verify(adiv5_dp_t *dp, uint32_t address, const uint8_t *data, size_t length)
{
    uint32_t value = 0U;
    uint32_t expected;
    size_t offset;
    size_t chunk;
    int rc;

    if ((dp == NULL) || ((data == NULL) && (length != 0U))) {
        return SWD_STATUS_ARGUMENT;
    }

    for (offset = 0U; offset < length; offset += 4U) {
        chunk = length - offset;
        if (chunk > 4U) {
            chunk = 4U;
        }

        rc = adiv5_mem_read32(dp, address + (uint32_t)offset, &value);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        expected = pack_word(data + offset, chunk);
        if (value != expected) {
            return SWD_STATUS_VERIFY;
        }
    }

    return SWD_STATUS_OK;
}
