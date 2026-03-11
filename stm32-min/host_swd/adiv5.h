#ifndef HOST_SWD_ADIV5_H
#define HOST_SWD_ADIV5_H

#include <stdint.h>

#include "swd_transport.h"

typedef struct
{
    swd_transport_t transport;
    uint32_t idcode;
    uint32_t select_cache;
    int select_valid;
} adiv5_dp_t;

int adiv5_open(adiv5_dp_t *dp, const swd_transport_options_t *options);
void adiv5_close(adiv5_dp_t *dp);
int adiv5_connect(adiv5_dp_t *dp);
int adiv5_read_idcode(adiv5_dp_t *dp, uint32_t *idcode);

int adiv5_dp_read(adiv5_dp_t *dp, uint8_t address, uint32_t *value);
int adiv5_dp_write(adiv5_dp_t *dp, uint8_t address, uint32_t value);
int adiv5_ap_read(adiv5_dp_t *dp, uint8_t address, uint32_t *value);
int adiv5_ap_write(adiv5_dp_t *dp, uint8_t address, uint32_t value);

int adiv5_mem_read32(adiv5_dp_t *dp, uint32_t address, uint32_t *value);
int adiv5_mem_write32(adiv5_dp_t *dp, uint32_t address, uint32_t value);

#endif
