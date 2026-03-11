#include <stddef.h>
#include <stdint.h>

#include "boot_image_format.h"
#include "stm32f401_boot_min.h"

typedef void (*app_entry_t)(void);

static void delay(volatile uint32_t cycles)
{
    while (cycles-- > 0U) {
        __asm volatile ("nop");
    }
}

static void led_init(void)
{
    RCC_AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    (void)RCC_AHB1ENR;

    GPIOA_MODER &= ~GPIO_MODER_MODE5_Msk;
    GPIOA_MODER |= GPIO_MODER_MODE5_OUT;
    GPIOA_OTYPER &= ~GPIO_OTYPER_OT5;
    GPIOA_OSPEEDR &= ~GPIO_OSPEEDR_OSPEED5_Msk;
    GPIOA_PUPDR &= ~GPIO_PUPDR_PUPD5_Msk;
}

static void led_on(void)
{
    GPIOA_BSRR = GPIO_BSRR_BS5;
}

static void led_off(void)
{
    GPIOA_BSRR = GPIO_BSRR_BR5;
}

static void blink_error_forever(uint32_t fast_cycles, uint32_t slow_cycles)
{
    while (1) {
        led_on();
        delay(fast_cycles);
        led_off();
        delay(slow_cycles);
    }
}

static uint32_t checksum_bytes(const uint8_t *data, uint32_t length)
{
    uint32_t sum = 0U;
    uint32_t index;

    for (index = 0U; index < length; ++index) {
        sum += data[index];
    }

    return sum;
}

static int is_valid_sram_pointer(uint32_t address)
{
    return (address >= SRAM_BASE_ADDR) &&
           (address < (SRAM_BASE_ADDR + SRAM_SIZE_BYTES));
}

static int is_valid_app_entry(uint32_t address)
{
    uint32_t raw_address = address & ~1UL;

    return (raw_address >= APP_FLASH_BASE) &&
           (raw_address < (APP_FLASH_BASE + APP_FLASH_SIZE));
}

static int app_vectors_look_valid(const uint8_t *image_base)
{
    const uint32_t *vector_table = (const uint32_t *)image_base;

    return is_valid_sram_pointer(vector_table[0]) &&
           is_valid_app_entry(vector_table[1]);
}

static int stage_image_is_ready(void)
{
    const boot_image_header_t *header =
        (const boot_image_header_t *)STAGE_FLASH_BASE;
    const uint8_t *payload =
        (const uint8_t *)(STAGE_FLASH_BASE + sizeof(boot_image_header_t));

    if (header->magic != BOOT_IMAGE_MAGIC) {
        return 0;
    }

    if ((header->image_size == 0U) || (header->image_size > APP_FLASH_SIZE)) {
        return 0;
    }

    if (!app_vectors_look_valid(payload)) {
        return 0;
    }

    return checksum_bytes(payload, header->image_size) == header->checksum;
}

static int app_slot_is_valid(void)
{
    const uint8_t *app_base = (const uint8_t *)APP_FLASH_BASE;
    const uint32_t *vector_table = (const uint32_t *)app_base;

    if ((vector_table[0] == 0xFFFFFFFFUL) || (vector_table[1] == 0xFFFFFFFFUL)) {
        return 0;
    }

    return app_vectors_look_valid(app_base);
}

static int flash_wait_ready(void)
{
    uint32_t status;

    while ((FLASH_SR & FLASH_SR_BSY) != 0U) {
    }

    status = FLASH_SR;
    FLASH_SR = status & (FLASH_SR_EOP | FLASH_SR_ERROR_MASK);

    return (status & FLASH_SR_ERROR_MASK) == 0U ? 0 : -1;
}

static void flash_unlock(void)
{
    if ((FLASH_CR & FLASH_CR_LOCK) == 0U) {
        return;
    }

    FLASH_KEYR = FLASH_KEY1;
    FLASH_KEYR = FLASH_KEY2;
}

static void flash_lock(void)
{
    FLASH_CR |= FLASH_CR_LOCK;
}

static int flash_erase_sector(uint32_t sector)
{
    uint32_t control = FLASH_CR;

    if (flash_wait_ready() != 0) {
        return -1;
    }

    control &= ~(FLASH_CR_SER | FLASH_CR_SNB_Msk | FLASH_CR_PSIZE_Msk | FLASH_CR_PG);
    control |= FLASH_CR_SER | FLASH_CR_PSIZE_X32 | (sector << FLASH_CR_SNB_Pos);
    FLASH_CR = control;
    FLASH_CR |= FLASH_CR_STRT;

    if (flash_wait_ready() != 0) {
        FLASH_CR &= ~(FLASH_CR_SER | FLASH_CR_SNB_Msk | FLASH_CR_PSIZE_Msk);
        return -1;
    }

    FLASH_CR &= ~(FLASH_CR_SER | FLASH_CR_SNB_Msk | FLASH_CR_PSIZE_Msk);
    return 0;
}

static int flash_program_word(uint32_t address, uint32_t value)
{
    uint32_t control = FLASH_CR;

    if ((address & 0x3UL) != 0U) {
        return -1;
    }

    if (flash_wait_ready() != 0) {
        return -1;
    }

    control &= ~(FLASH_CR_SER | FLASH_CR_SNB_Msk | FLASH_CR_PSIZE_Msk);
    control |= FLASH_CR_PG | FLASH_CR_PSIZE_X32;
    FLASH_CR = control;

    *(volatile uint32_t *)address = value;

    if (flash_wait_ready() != 0) {
        FLASH_CR &= ~(FLASH_CR_PG | FLASH_CR_PSIZE_Msk);
        return -1;
    }

    FLASH_CR &= ~(FLASH_CR_PG | FLASH_CR_PSIZE_Msk);
    return (*(volatile uint32_t *)address == value) ? 0 : -1;
}

static uint32_t load_padded_word(const uint8_t *data, uint32_t remaining)
{
    uint32_t word = 0xFFFFFFFFUL;
    uint32_t index;

    for (index = 0U; index < 4U; ++index) {
        uint32_t byte_value = 0xFFU;

        if (index < remaining) {
            byte_value = data[index];
        }

        word &= ~(0xFFUL << (index * 8U));
        word |= byte_value << (index * 8U);
    }

    return word;
}

static int program_app_from_stage(void)
{
    const boot_image_header_t *header =
        (const boot_image_header_t *)STAGE_FLASH_BASE;
    const uint8_t *payload =
        (const uint8_t *)(STAGE_FLASH_BASE + sizeof(boot_image_header_t));
    uint32_t offset;
    uint32_t remaining;

    if (!stage_image_is_ready()) {
        return -1;
    }

    flash_unlock();

    if ((flash_erase_sector(2U) != 0) ||
        (flash_erase_sector(3U) != 0) ||
        (flash_erase_sector(4U) != 0)) {
        flash_lock();
        return -1;
    }

    for (offset = 0U; offset < header->image_size; offset += 4U) {
        remaining = header->image_size - offset;
        if (remaining > 4U) {
            remaining = 4U;
        }

        if (flash_program_word(APP_FLASH_BASE + offset,
                               load_padded_word(payload + offset, remaining)) != 0) {
            flash_lock();
            return -1;
        }
    }

    flash_lock();

    for (offset = 0U; offset < header->image_size; ++offset) {
        if (*(const uint8_t *)(APP_FLASH_BASE + offset) != payload[offset]) {
            return -1;
        }
    }

    if (!app_slot_is_valid()) {
        return -1;
    }

    flash_unlock();
    if (flash_program_word(STAGE_FLASH_BASE + offsetof(boot_image_header_t, magic), 0U) != 0) {
        flash_lock();
        return -1;
    }
    flash_lock();

    return 0;
}

static void jump_to_app(void)
{
    const uint32_t *vector_table = (const uint32_t *)APP_FLASH_BASE;
    uint32_t app_stack = vector_table[0];
    uint32_t app_reset = vector_table[1];
    app_entry_t app_entry = (app_entry_t)app_reset;

    __asm volatile ("cpsid i");
    SCB_VTOR = APP_FLASH_BASE;
    __asm volatile ("dsb");
    __asm volatile ("isb");
    __asm volatile ("msr msp, %0" : : "r" (app_stack) : );
    __asm volatile ("cpsie i");

    app_entry();

    while (1) {
    }
}

int main(void)
{
    led_init();
    led_off();

    if (stage_image_is_ready()) {
        if (program_app_from_stage() != 0) {
            blink_error_forever(40000U, 40000U);
        }
    }

    if (app_slot_is_valid()) {
        jump_to_app();
    }

    blink_error_forever(120000U, 120000U);
}
