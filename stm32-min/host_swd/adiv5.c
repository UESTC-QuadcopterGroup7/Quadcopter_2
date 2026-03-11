#include <stddef.h>
#include <string.h>

#include "adiv5.h"
#include "swd_protocol.h"
#include "swd_status.h"

static int adiv5_transfer_checked(adiv5_dp_t *dp, uint8_t request, uint32_t *data)
{
    uint8_t ack = 0U;
    int rc;
    unsigned int attempt;

    for (attempt = 0U; attempt < 100U; ++attempt) {
        rc = swd_transport_transfer(&dp->transport, request, data, &ack);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        if (ack == SWD_ACK_OK) {
            return SWD_STATUS_OK;
        }

        if (ack != SWD_ACK_WAIT) {
            break;
        }
    }

    if (ack == SWD_ACK_WAIT) {
        return SWD_STATUS_ACK_WAIT;
    }

    if (ack == SWD_ACK_FAULT) {
        return SWD_STATUS_ACK_FAULT;
    }

    return SWD_STATUS_ACK_PROTOCOL;
}

static int adiv5_select(adiv5_dp_t *dp, uint32_t value)
{
    int rc;

    if ((dp->select_valid != 0) && (dp->select_cache == value)) {
        return SWD_STATUS_OK;
    }

    rc = adiv5_dp_write(dp, SWD_DP_SELECT, value);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    dp->select_cache = value;
    dp->select_valid = 1;
    return SWD_STATUS_OK;
}

int adiv5_open(adiv5_dp_t *dp, const swd_transport_options_t *options)
{
    if (dp == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    memset(dp, 0, sizeof(*dp));
    return swd_transport_open(&dp->transport, options);
}

void adiv5_close(adiv5_dp_t *dp)
{
    if (dp != NULL) {
        swd_transport_close(&dp->transport);
    }
}

int adiv5_connect(adiv5_dp_t *dp)
{
    uint32_t idcode = 0U;
    uint32_t ctrl_stat = 0U;
    unsigned int attempt;
    int rc;

    if (dp == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    rc = swd_transport_line_reset(&dp->transport);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = swd_transport_jtag_to_swd(&dp->transport);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = swd_transport_line_reset(&dp->transport);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_read_idcode(dp, &idcode);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    dp->idcode = idcode;

    rc = adiv5_dp_write(dp,
                        SWD_DP_ABORT,
                        SWD_ABORT_ORUNERRCLR |
                        SWD_ABORT_WDERRCLR |
                        SWD_ABORT_STKERRCLR |
                        SWD_ABORT_STKCMPCLR);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_dp_write(dp,
                        SWD_DP_CTRL_STAT,
                        SWD_CTRLSTAT_CSYSPWRUPREQ |
                        SWD_CTRLSTAT_CDBGPWRUPREQ);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    for (attempt = 0U; attempt < 1000U; ++attempt) {
        rc = adiv5_dp_read(dp, SWD_DP_CTRL_STAT, &ctrl_stat);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        if ((ctrl_stat & (SWD_CTRLSTAT_CSYSPWRUPACK | SWD_CTRLSTAT_CDBGPWRUPACK)) ==
            (SWD_CTRLSTAT_CSYSPWRUPACK | SWD_CTRLSTAT_CDBGPWRUPACK)) {
            return SWD_STATUS_OK;
        }
    }

    return SWD_STATUS_TARGET;
}

int adiv5_read_idcode(adiv5_dp_t *dp, uint32_t *idcode)
{
    return adiv5_dp_read(dp, SWD_DP_IDCODE, idcode);
}

int adiv5_dp_read(adiv5_dp_t *dp, uint8_t address, uint32_t *value)
{
    uint8_t request;

    if ((dp == NULL) || (value == NULL)) {
        return SWD_STATUS_ARGUMENT;
    }

    request = swd_make_request(0U, 1U, address);
    return adiv5_transfer_checked(dp, request, value);
}

int adiv5_dp_write(adiv5_dp_t *dp, uint8_t address, uint32_t value)
{
    uint32_t local_value = value;
    uint8_t request;

    if (dp == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    request = swd_make_request(0U, 0U, address);
    return adiv5_transfer_checked(dp, request, &local_value);
}

int adiv5_ap_read(adiv5_dp_t *dp, uint8_t address, uint32_t *value)
{
    uint32_t ignored = 0U;
    uint32_t select_value;
    uint8_t request;
    int rc;

    if ((dp == NULL) || (value == NULL)) {
        return SWD_STATUS_ARGUMENT;
    }

    select_value = (0U << SWD_SELECT_APSEL_Pos) |
                   ((uint32_t)(address & 0xF0U) << SWD_SELECT_APBANKSEL_Pos);
    rc = adiv5_select(dp, select_value);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    request = swd_make_request(1U, 1U, address);
    rc = adiv5_transfer_checked(dp, request, &ignored);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return adiv5_dp_read(dp, SWD_DP_RDBUFF, value);
}

int adiv5_ap_write(adiv5_dp_t *dp, uint8_t address, uint32_t value)
{
    uint32_t local_value = value;
    uint32_t select_value;
    uint8_t request;
    int rc;

    if (dp == NULL) {
        return SWD_STATUS_ARGUMENT;
    }

    select_value = (0U << SWD_SELECT_APSEL_Pos) |
                   ((uint32_t)(address & 0xF0U) << SWD_SELECT_APBANKSEL_Pos);
    rc = adiv5_select(dp, select_value);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    request = swd_make_request(1U, 0U, address);
    return adiv5_transfer_checked(dp, request, &local_value);
}

int adiv5_mem_read32(adiv5_dp_t *dp, uint32_t address, uint32_t *value)
{
    int rc;

    rc = adiv5_ap_write(dp, SWD_AP_CSW, SWD_MEM_AP_CSW_VALUE);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_ap_write(dp, SWD_AP_TAR, address);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return adiv5_ap_read(dp, SWD_AP_DRW, value);
}

int adiv5_mem_write32(adiv5_dp_t *dp, uint32_t address, uint32_t value)
{
    int rc;

    rc = adiv5_ap_write(dp, SWD_AP_CSW, SWD_MEM_AP_CSW_VALUE);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = adiv5_ap_write(dp, SWD_AP_TAR, address);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return adiv5_ap_write(dp, SWD_AP_DRW, value);
}
