#ifndef BOOT_IMAGE_FORMAT_H
#define BOOT_IMAGE_FORMAT_H

#include <stdint.h>

#define BOOTLOADER_FLASH_BASE   0x08000000UL
#define BOOTLOADER_FLASH_SIZE   0x00008000UL

#define APP_FLASH_BASE          0x08008000UL
#define APP_FLASH_SIZE          0x00018000UL

#define STAGE_FLASH_BASE        0x08020000UL
#define STAGE_FLASH_SIZE        0x00060000UL

#define BOOT_IMAGE_MAGIC        0x424C4452UL

typedef struct
{
    uint32_t magic;
    uint32_t image_size;
    uint32_t checksum;
    uint32_t reserved;
} boot_image_header_t;

#endif
