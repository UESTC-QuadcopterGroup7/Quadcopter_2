#include <stdint.h>

#include "cortexm.h"
#include "swd_status.h"

#define CORTEXM_DHCSR   0xE000EDF0UL
#define CORTEXM_DEMCR   0xE000EDFCUL
#define CORTEXM_AIRCR   0xE000ED0CUL

#define CORTEXM_DHCSR_DBGKEY      0xA05F0000UL
#define CORTEXM_DHCSR_C_DEBUGEN   (1UL << 0)
#define CORTEXM_DHCSR_C_HALT      (1UL << 1)
#define CORTEXM_DHCSR_S_HALT      (1UL << 17)

#define CORTEXM_DEMCR_VC_CORERESET (1UL << 0)

#define CORTEXM_AIRCR_VECTKEY     0x05FA0000UL
#define CORTEXM_AIRCR_SYSRESETREQ (1UL << 2)

static int cortexm_wait_halted(adiv5_dp_t *dp)
{
    uint32_t dhcsr = 0U;
    unsigned int attempt;
    int rc;

    for (attempt = 0U; attempt < 1000U; ++attempt) {
        rc = adiv5_mem_read32(dp, CORTEXM_DHCSR, &dhcsr);
        if (rc != SWD_STATUS_OK) {
            return rc;
        }

        if ((dhcsr & CORTEXM_DHCSR_S_HALT) != 0U) {
            return SWD_STATUS_OK;
        }
    }

    return SWD_STATUS_TARGET;
}

int cortexm_halt(adiv5_dp_t *dp)
{
    int rc;

    rc = adiv5_mem_write32(dp,
                           CORTEXM_DHCSR,
                           CORTEXM_DHCSR_DBGKEY |
                           CORTEXM_DHCSR_C_DEBUGEN |
                           CORTEXM_DHCSR_C_HALT);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return cortexm_wait_halted(dp);
}

int cortexm_run(adiv5_dp_t *dp)
{
    return adiv5_mem_write32(dp,
                             CORTEXM_DHCSR,
                             CORTEXM_DHCSR_DBGKEY |
                             CORTEXM_DHCSR_C_DEBUGEN);
}

int cortexm_system_reset(adiv5_dp_t *dp)
{
    return adiv5_mem_write32(dp,
                             CORTEXM_AIRCR,
                             CORTEXM_AIRCR_VECTKEY |
                             CORTEXM_AIRCR_SYSRESETREQ);
}

int cortexm_reset_halt(adiv5_dp_t *dp)
{
    int rc;

    rc = adiv5_mem_write32(dp, CORTEXM_DEMCR, CORTEXM_DEMCR_VC_CORERESET);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = cortexm_system_reset(dp);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    rc = cortexm_wait_halted(dp);
    if (rc != SWD_STATUS_OK) {
        return rc;
    }

    return adiv5_mem_write32(dp, CORTEXM_DEMCR, 0U);
}
