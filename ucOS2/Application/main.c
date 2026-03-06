#include "ucos_ii.h"
#include "app_cfg.h"

static OS_STK AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE];

static void AppTaskStart(void *p_arg)
{
    (void)p_arg;

    while (1) {
        OSTimeDly(10);
    }
}

int main(void)
{
    OSInit();

    OSTaskCreate(
        AppTaskStart,
        (void *)0,
        &AppTaskStartStk[APP_CFG_STARTUP_TASK_STK_SIZE - 1],
        APP_CFG_STARTUP_TASK_PRIO
    );

    OSStart();

    return 0;
}