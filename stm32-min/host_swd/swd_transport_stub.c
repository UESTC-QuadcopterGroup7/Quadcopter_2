#include <stddef.h>
#include <string.h>

#include "swd_status.h"
#include "swd_transport.h"

static int stub_open(swd_transport_t *transport, const swd_transport_options_t *options)
{
    (void)transport;

    if ((options != NULL) &&
        (options->backend_name != NULL) &&
        (strcmp(options->backend_name, "stub") != 0)) {
        return SWD_STATUS_UNSUPPORTED;
    }

    return SWD_STATUS_OK;
}

static void stub_close(swd_transport_t *transport)
{
    (void)transport;
}

static int stub_line_reset(swd_transport_t *transport)
{
    (void)transport;
    return SWD_STATUS_OK;
}

static int stub_jtag_to_swd(swd_transport_t *transport)
{
    (void)transport;
    return SWD_STATUS_OK;
}

static int stub_target_reset(swd_transport_t *transport)
{
    (void)transport;
    return SWD_STATUS_UNSUPPORTED;
}

static int stub_transfer(swd_transport_t *transport, uint8_t request, uint32_t *data, uint8_t *ack)
{
    (void)transport;
    (void)request;

    if (data != NULL) {
        *data = 0U;
    }

    if (ack != NULL) {
        *ack = 0U;
    }

    return SWD_STATUS_UNSUPPORTED;
}

static const swd_transport_ops_t g_stub_ops = {
    "stub",
    stub_open,
    stub_close,
    stub_line_reset,
    stub_jtag_to_swd,
    stub_target_reset,
    stub_transfer
};

int swd_transport_open(swd_transport_t *transport, const swd_transport_options_t *options)
{
    if (transport == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    transport->ops = &g_stub_ops;
    return transport->ops->open(transport, options);
}

void swd_transport_close(swd_transport_t *transport)
{
    if ((transport != NULL) && (transport->ops != NULL) && (transport->ops->close != NULL)) {
        transport->ops->close(transport);
    }
}

int swd_transport_line_reset(swd_transport_t *transport)
{
    if ((transport == NULL) || (transport->ops == NULL) || (transport->ops->line_reset == NULL)) {
        return SWD_STATUS_TRANSPORT;
    }

    return transport->ops->line_reset(transport);
}

int swd_transport_jtag_to_swd(swd_transport_t *transport)
{
    if ((transport == NULL) || (transport->ops == NULL) || (transport->ops->jtag_to_swd == NULL)) {
        return SWD_STATUS_TRANSPORT;
    }

    return transport->ops->jtag_to_swd(transport);
}

int swd_transport_target_reset(swd_transport_t *transport)
{
    if ((transport == NULL) || (transport->ops == NULL) || (transport->ops->target_reset == NULL)) {
        return SWD_STATUS_TRANSPORT;
    }

    return transport->ops->target_reset(transport);
}

int swd_transport_transfer(swd_transport_t *transport, uint8_t request, uint32_t *data, uint8_t *ack)
{
    if ((transport == NULL) || (transport->ops == NULL) || (transport->ops->transfer == NULL)) {
        return SWD_STATUS_TRANSPORT;
    }

    return transport->ops->transfer(transport, request, data, ack);
}

const char *swd_transport_backend_name(const swd_transport_t *transport)
{
    if ((transport == NULL) || (transport->ops == NULL) || (transport->ops->backend_name == NULL)) {
        return "unknown";
    }

    return transport->ops->backend_name;
}
