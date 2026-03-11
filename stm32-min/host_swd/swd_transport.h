#ifndef HOST_SWD_TRANSPORT_H
#define HOST_SWD_TRANSPORT_H

#include <stdint.h>

typedef struct swd_transport swd_transport_t;

typedef struct
{
    const char *backend_name;
} swd_transport_options_t;

typedef struct
{
    const char *backend_name;
    int (*open)(swd_transport_t *transport, const swd_transport_options_t *options);
    void (*close)(swd_transport_t *transport);
    int (*line_reset)(swd_transport_t *transport);
    int (*jtag_to_swd)(swd_transport_t *transport);
    int (*target_reset)(swd_transport_t *transport);
    int (*transfer)(swd_transport_t *transport, uint8_t request, uint32_t *data, uint8_t *ack);
} swd_transport_ops_t;

struct swd_transport
{
    const swd_transport_ops_t *ops;
};

int swd_transport_open(swd_transport_t *transport, const swd_transport_options_t *options);
void swd_transport_close(swd_transport_t *transport);
int swd_transport_line_reset(swd_transport_t *transport);
int swd_transport_jtag_to_swd(swd_transport_t *transport);
int swd_transport_target_reset(swd_transport_t *transport);
int swd_transport_transfer(swd_transport_t *transport, uint8_t request, uint32_t *data, uint8_t *ack);
const char *swd_transport_backend_name(const swd_transport_t *transport);

#endif
