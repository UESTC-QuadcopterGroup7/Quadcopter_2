#ifndef HOST_SWD_CORTEXM_H
#define HOST_SWD_CORTEXM_H

#include "adiv5.h"

int cortexm_halt(adiv5_dp_t *dp);
int cortexm_run(adiv5_dp_t *dp);
int cortexm_system_reset(adiv5_dp_t *dp);
int cortexm_reset_halt(adiv5_dp_t *dp);

#endif
