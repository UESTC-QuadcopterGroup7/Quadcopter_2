#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "boot_image_format.h"

static uint32_t checksum_bytes(const uint8_t *data, size_t length)
{
    uint32_t sum = 0U;
    size_t index;

    for (index = 0U; index < length; ++index) {
        sum += data[index];
    }

    return sum;
}

int main(int argc, char **argv)
{
    FILE *input;
    FILE *output;
    long raw_size;
    size_t image_size;
    uint8_t *buffer;
    boot_image_header_t header;

    if (argc != 3) {
        fprintf(stderr, "usage: %s <app.bin> <stage.bin>\n", argv[0]);
        return 1;
    }

    input = fopen(argv[1], "rb");
    if (input == NULL) {
        perror("open input");
        return 1;
    }

    if (fseek(input, 0L, SEEK_END) != 0) {
        perror("seek input");
        fclose(input);
        return 1;
    }

    raw_size = ftell(input);
    if (raw_size < 0L) {
        perror("size input");
        fclose(input);
        return 1;
    }

    if (fseek(input, 0L, SEEK_SET) != 0) {
        perror("rewind input");
        fclose(input);
        return 1;
    }

    image_size = (size_t)raw_size;
    if ((image_size == 0U) || (image_size > APP_FLASH_SIZE)) {
        fprintf(stderr, "input image size %lu is outside app slot size %lu\n",
                (unsigned long)image_size,
                (unsigned long)APP_FLASH_SIZE);
        fclose(input);
        return 1;
    }

    buffer = (uint8_t *)malloc(image_size);
    if (buffer == NULL) {
        fprintf(stderr, "out of memory\n");
        fclose(input);
        return 1;
    }

    if (fread(buffer, 1U, image_size, input) != image_size) {
        perror("read input");
        free(buffer);
        fclose(input);
        return 1;
    }
    fclose(input);

    header.magic = BOOT_IMAGE_MAGIC;
    header.image_size = (uint32_t)image_size;
    header.checksum = checksum_bytes(buffer, image_size);
    header.reserved = 0U;

    output = fopen(argv[2], "wb");
    if (output == NULL) {
        perror("open output");
        free(buffer);
        return 1;
    }

    if (fwrite(&header, sizeof(header), 1U, output) != 1U) {
        perror("write header");
        free(buffer);
        fclose(output);
        return 1;
    }

    if (fwrite(buffer, 1U, image_size, output) != image_size) {
        perror("write payload");
        free(buffer);
        fclose(output);
        return 1;
    }

    while ((ftell(output) & 3L) != 0L) {
        if (fputc(0xFF, output) == EOF) {
            perror("pad output");
            free(buffer);
            fclose(output);
            return 1;
        }
    }

    free(buffer);

    if (fclose(output) != 0) {
        perror("close output");
        return 1;
    }

    return 0;
}
