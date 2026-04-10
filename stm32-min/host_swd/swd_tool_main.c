#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "adiv5.h"
#include "cortexm.h"
#include "stm32f4_flash.h"
#include "swd_status.h"

typedef struct
{
    const char *program_name;
    const char *backend_name;
} cli_options_t;

static void print_usage(const char *program_name)
{
    fprintf(stderr,
            "usage:\n"
            "  %s [--backend stub] probe\n"
            "  %s [--backend stub] erase <address> <length>\n"
            "  %s [--backend stub] write <file.bin> <address>\n"
            "  %s [--backend stub] verify <file.bin> <address>\n"
            "  %s [--backend stub] reset\n",
            program_name,
            program_name,
            program_name,
            program_name,
            program_name);
}

static int parse_u32(const char *text, uint32_t *value)
{
    unsigned long parsed = 0UL;
    char *end = NULL;

    if ((text == NULL) || (value == NULL)) {
        return SWD_STATUS_ARGUMENT;
    }

    errno = 0;
    parsed = strtoul(text, &end, 0);
    if ((errno != 0) || (end == text) || ((end != NULL) && (*end != '\0'))) {
        return SWD_STATUS_ARGUMENT;
    }

    *value = (uint32_t)parsed;
    return SWD_STATUS_OK;
}

static int read_file(const char *path, uint8_t **buffer, size_t *size)
{
    FILE *file = NULL;
    long raw_size = 0L;
    uint8_t *local_buffer = NULL;

    if ((path == NULL) || (buffer == NULL) || (size == NULL)) {
        return SWD_STATUS_ARGUMENT;
    }

    file = fopen(path, "rb");
    if (file == NULL) {
        return SWD_STATUS_IO;
    }

    if (fseek(file, 0L, SEEK_END) != 0) {
        fclose(file);
        return SWD_STATUS_IO;
    }

    raw_size = ftell(file);
    if (raw_size < 0L) {
        fclose(file);
        return SWD_STATUS_IO;
    }

    if (fseek(file, 0L, SEEK_SET) != 0) {
        fclose(file);
        return SWD_STATUS_IO;
    }

    local_buffer = (uint8_t *)malloc((size_t)raw_size);
    if ((local_buffer == NULL) && (raw_size != 0L)) {
        fclose(file);
        return SWD_STATUS_IO;
    }

    if ((size_t)raw_size != fread(local_buffer, 1U, (size_t)raw_size, file)) {
        free(local_buffer);
        fclose(file);
        return SWD_STATUS_IO;
    }

    fclose(file);
    *buffer = local_buffer;
    *size = (size_t)raw_size;
    return SWD_STATUS_OK;
}

static int open_target(adiv5_dp_t *dp, const cli_options_t *options)
{
    swd_transport_options_t transport_options;
    int rc;

    transport_options.backend_name = options->backend_name;

    rc = adiv5_open(dp, &transport_options);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_connect(dp);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return SWD_STATUS_OK;
}

static int command_probe(const cli_options_t *options)
{
    adiv5_dp_t dp;
    int rc;

    rc = open_target(&dp, options);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    printf("backend: %s\n", swd_transport_backend_name(&dp.transport));
    printf("dp idcode: 0x%08lX\n", (unsigned long)dp.idcode);

    adiv5_close(&dp);
    return SWD_STATUS_OK;
}

static int command_erase(const cli_options_t *options, const char *address_text, const char *length_text)
{
    adiv5_dp_t dp;
    uint32_t address = 0U;
    uint32_t length = 0U;
    int rc;

    rc = parse_u32(address_text, &address);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = parse_u32(length_text, &length);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = open_target(&dp, options);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = cortexm_halt(&dp);
    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_unlock(&dp);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_erase(&dp, address, length);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_lock(&dp);
    }

    adiv5_close(&dp);
    return rc;
}

static int command_write(const cli_options_t *options, const char *path, const char *address_text)
{
    adiv5_dp_t dp;
    uint8_t *buffer = NULL;
    size_t size = 0U;
    uint32_t address = 0U;
    int rc;

    rc = parse_u32(address_text, &address);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = read_file(path, &buffer, &size);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = open_target(&dp, options);
    if (rc == SWD_STATUS_OK) {
        rc = cortexm_halt(&dp);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_unlock(&dp);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_erase(&dp, address, (uint32_t)size);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_program(&dp, address, buffer, size);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_verify(&dp, address, buffer, size);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_lock(&dp);
    }

    adiv5_close(&dp);
    free(buffer);
    return rc;
}

static int command_verify(const cli_options_t *options, const char *path, const char *address_text)
{
    adiv5_dp_t dp;
    uint8_t *buffer = NULL;
    size_t size = 0U;
    uint32_t address = 0U;
    int rc;

    rc = parse_u32(address_text, &address);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = read_file(path, &buffer, &size);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = open_target(&dp, options);
    if (rc == SWD_STATUS_OK) {
        rc = cortexm_halt(&dp);
    }

    if (rc == SWD_STATUS_OK) {
        rc = stm32f4_flash_verify(&dp, address, buffer, size);
    }

    adiv5_close(&dp);
    free(buffer);
    return rc;
}

static int command_reset(const cli_options_t *options)
{
    adiv5_dp_t dp;
    int rc;

    rc = open_target(&dp, options);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = cortexm_system_reset(&dp);
    adiv5_close(&dp);
    return rc;
}

int main(int argc, char **argv)
{
    cli_options_t options;
    const char *command = NULL;
    int argi = 1;
    int rc;

    options.program_name = (argc > 0) ? argv[0] : "swd_host_tool";
    options.backend_name = "stub";

    while ((argi < argc) && (strcmp(argv[argi], "--backend") == 0)) {
        if ((argi + 1) >= argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }

        options.backend_name = argv[argi + 1];
        argi += 2;
    }

    if (argi >= argc) {
        print_usage(options.program_name);
        return SWD_STATUS_ARGUMENT;
    }

    command = argv[argi++];

    if (strcmp(command, "probe") == 0) {
        if (argi != argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }
        rc = command_probe(&options);
    } else if (strcmp(command, "erase") == 0) {
        if ((argi + 2) != argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }
        rc = command_erase(&options, argv[argi], argv[argi + 1]);
    } else if (strcmp(command, "write") == 0) {
        if ((argi + 2) != argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }
        rc = command_write(&options, argv[argi], argv[argi + 1]);
    } else if (strcmp(command, "verify") == 0) {
        if ((argi + 2) != argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }
        rc = command_verify(&options, argv[argi], argv[argi + 1]);
    } else if (strcmp(command, "reset") == 0) {
        if (argi != argc) {
            print_usage(options.program_name);
            return SWD_STATUS_ARGUMENT;
        }
        rc = command_reset(&options);
    } else {
        print_usage(options.program_name);
        return SWD_STATUS_ARGUMENT;
    }

    if (rc != SWD_STATUS_OK) {
        fprintf(stderr, "error: %s\n", swd_status_string(rc));
        if (rc == SWD_STATUS_UNSUPPORTED) {
            fprintf(stderr,
                    "hint: only the transport-independent SWD stack is implemented.\n"
                    "      add a real backend in host_swd/swd_transport_*.c to talk to hardware.\n");
        }
    }

    return rc == SWD_STATUS_OK ? 0 : 1;
}
