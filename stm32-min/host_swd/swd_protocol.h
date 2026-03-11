#ifndef HOST_SWD_PROTOCOL_H
#define HOST_SWD_PROTOCOL_H

#include <stdint.h>

#define SWD_ACK_OK        0x1U
#define SWD_ACK_WAIT      0x2U
#define SWD_ACK_FAULT     0x4U

#define SWD_DP_ABORT      0x00U
#define SWD_DP_IDCODE     0x00U
#define SWD_DP_CTRL_STAT  0x04U
#define SWD_DP_SELECT     0x08U
#define SWD_DP_RDBUFF     0x0CU

#define SWD_AP_CSW        0x00U
#define SWD_AP_TAR        0x04U
#define SWD_AP_DRW        0x0CU

#define SWD_ABORT_ORUNERRCLR  (1UL << 4)
#define SWD_ABORT_WDERRCLR    (1UL << 3)
#define SWD_ABORT_STKERRCLR   (1UL << 2)
#define SWD_ABORT_STKCMPCLR   (1UL << 1)

#define SWD_CTRLSTAT_CSYSPWRUPREQ  (1UL << 30)
#define SWD_CTRLSTAT_CSYSPWRUPACK  (1UL << 31)
#define SWD_CTRLSTAT_CDBGPWRUPREQ  (1UL << 28)
#define SWD_CTRLSTAT_CDBGPWRUPACK  (1UL << 29)

#define SWD_SELECT_APSEL_Pos       24U
#define SWD_SELECT_APBANKSEL_Pos   4U

#define SWD_MEM_AP_CSW_VALUE       0x23000052UL

static inline uint8_t swd_make_request(uint8_t apndp, uint8_t rnw, uint8_t address)
{
    uint8_t a2 = (uint8_t)((address >> 2) & 1U);
    uint8_t a3 = (uint8_t)((address >> 3) & 1U);
    uint8_t parity = (uint8_t)((apndp ^ rnw ^ a2 ^ a3) & 1U);

    return (uint8_t)(1U |
                     (apndp << 1) |
                     (rnw << 2) |
                     (a2 << 3) |
                     (a3 << 4) |
                     (parity << 5) |
                     (1U << 7));
}

#endif
