#include <ucos_ii.h>

/*
 * SysTick Defines
 */
#define  OS_CPU_CM_SYST_CSR         (*((volatile INT32U *)0xE000E010uL)) /* SysTick Ctrl & Status Reg.                  */
#define  OS_CPU_CM_SYST_RVR         (*((volatile INT32U *)0xE000E014uL)) /* SysTick Reload  Value Reg.                  */
#define  OS_CPU_CM_SYST_CVR         (*((volatile INT32U *)0xE000E018uL)) /* SysTick Current Value Reg.                  */
#define  OS_CPU_CM_SYST_CALIB       (*((volatile INT32U *)0xE000E01CuL)) /* SysTick Cal     Value Reg.                  */
#define  OS_CPU_CM_SCB_SHPRI1       (*((volatile INT32U *)0xE000ED18uL)) /* System Handlers  4 to  7 Prio.              */
#define  OS_CPU_CM_SCB_SHPRI2       (*((volatile INT32U *)0xE000ED1CuL)) /* System Handlers  8 to 11 Prio.              */
#define  OS_CPU_CM_SCB_SHPRI3       (*((volatile INT32U *)0xE000ED20uL)) /* System Handlers 12 to 15 Prio.              */


#define  OS_CPU_CM_SYST_CSR_COUNTFLAG                     0x00010000uL   /* Count flag.                                 */
#define  OS_CPU_CM_SYST_CSR_CLKSOURCE                     0x00000004uL   /* Clock Source.                               */
#define  OS_CPU_CM_SYST_CSR_TICKINT                       0x00000002uL   /* Interrupt enable.                           */
#define  OS_CPU_CM_SYST_CSR_ENABLE                        0x00000001uL   /* Counter mode.                               */


/*
 * CPU Hooks
 */
#if OS_CPU_HOOKS_EN > 0
void OSInitHookBegin(void) {}
#endif

#if OS_CPU_HOOKS_EN > 0
void  OSInitHookEnd (void) {}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTCBInitHook(OS_TCB *ptcb) {
    (void) ptcb;
}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskCreateHook(OS_TCB *ptcb) {
    (void) ptcb;
}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskIdleHook(void) {}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskStatHook(void) {}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTimeTickHook(void) {}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskDelHook(OS_TCB *ptcb) {
    (void) ptcb;
}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskReturnHook(OS_TCB *ptcb) {
    (void) ptcb;
}
#endif

#if OS_CPU_HOOKS_EN > 0
void OSTaskSwHook(void) {}
#endif

/*
 * SystickInit of OS
 */
void  OS_CPU_SysTickInit (INT32U  cnts)
{
    INT32U  prio;
    INT32U  basepri;


                                                                /* Set BASEPRI boundary from the configuration.         */
    basepri               = (INT32U)(CPU_CFG_KA_IPL_BOUNDARY << (8u - CPU_CFG_NVIC_PRIO_BITS));
    OS_CPU_CM_SYST_RVR    = cnts - 1u;                          /* Set Reload register.                                 */

                                                                /* Set SysTick handler prio.                            */
    prio                  =  OS_CPU_CM_SCB_SHPRI3;
    prio                 &=  0x00FFFFFFu;
    prio                 |= (basepri << 24u);
    OS_CPU_CM_SCB_SHPRI3  = prio;

                                                                /* Enable timer.                                        */
    OS_CPU_CM_SYST_CSR   |= OS_CPU_CM_SYST_CSR_CLKSOURCE |
                            OS_CPU_CM_SYST_CSR_ENABLE;
                                                                /* Enable timer interrupt.                              */
    OS_CPU_CM_SYST_CSR   |= OS_CPU_CM_SYST_CSR_TICKINT;
}

void  OS_CPU_SysTickInitFreq (INT32U  cpu_freq)
{
    INT32U  cnts;


    cnts = (cpu_freq / (INT32U)OS_TICKS_PER_SEC);               /* Determine nbr SysTick cnts between two OS tick intr. */

    OS_CPU_SysTickInit(cnts);
}

/*
 * Init Stack of a task
 */
OS_STK *OSTaskStkInit (void (*task)(void *p_arg), void *p_arg, OS_STK *ptos, INT16U opt)
{
    OS_STK *p_stk;


    (void)opt;                                                  /* 'opt' is not used, prevent warning                   */
    p_stk      = ptos + 1u;                                     /* Load stack pointer                                   */
                                                                /* Align the stack to 8-bytes.                          */
    p_stk      = (OS_STK *)((OS_STK)(p_stk) & 0xFFFFFFF8u);
                                                                /* Registers stacked as if auto-saved on exception      */
    *(--p_stk) = (OS_STK)0x01000000uL;                          /* xPSR                                                 */
    *(--p_stk) = (OS_STK)task;                                  /* Entry Point                                          */
    *(--p_stk) = (OS_STK)OS_TaskReturn;                         /* R14 (LR)                                             */
    *(--p_stk) = (OS_STK)0x12121212uL;                          /* R12                                                  */
    *(--p_stk) = (OS_STK)0x03030303uL;                          /* R3                                                   */
    *(--p_stk) = (OS_STK)0x02020202uL;                          /* R2                                                   */
    *(--p_stk) = (OS_STK)0x01010101uL;                          /* R1                                                   */
    *(--p_stk) = (OS_STK)p_arg;                                 /* R0 : argument                                        */

                                                                /* Remaining registers saved on process stack           */
    *(--p_stk) = (OS_STK)0x11111111uL;                          /* R11                                                  */
    *(--p_stk) = (OS_STK)0x10101010uL;                          /* R10                                                  */
    *(--p_stk) = (OS_STK)0x09090909uL;                          /* R9                                                   */
    *(--p_stk) = (OS_STK)0x08080808uL;                          /* R8                                                   */
    *(--p_stk) = (OS_STK)0x07070707uL;                          /* R7                                                   */
    *(--p_stk) = (OS_STK)0x06060606uL;                          /* R6                                                   */
    *(--p_stk) = (OS_STK)0x05050505uL;                          /* R5                                                   */
    *(--p_stk) = (OS_STK)0x04040404uL;                          /* R4                                                   */

    return (p_stk);
}
