#include "main.h"
#include "stm32f4xx_it.h"
#include "ucos_ii.h"

void NMI_Handler(void) {}
void HardFault_Handler(void) { while(1) {} }
void MemManage_Handler(void) { while(1) {} }
void BusFault_Handler(void) { while(1) {} }
void UsageFault_Handler(void) { while(1) {} }
void SVC_Handler(void) {}
void DebugMon_Handler(void) {}

// void Systick_Handler(void) {

// #if OS_CRITICAL_METHOD == 3u
//     OS_CPU_SR cpu_sr;
// #endif

//     OS_ENTER_CRITICAL();
//     OSIntEnter();
//     OS_EXIT_CRITICAL();

//     OSTimeTick();
//     OSIntExit();
// }

void  OS_CPU_SysTickHandler (void)
{
#if OS_CRITICAL_METHOD == 3u                                    /* Allocate storage for CPU status register             */
    OS_CPU_SR  cpu_sr;
#endif


    OS_ENTER_CRITICAL();
    OSIntEnter();                                               /* Tell uC/OS-II that we are starting an ISR            */
    OS_EXIT_CRITICAL();

    OSTimeTick();                                               /* Call uC/OS-II's OSTimeTick()                         */

    OSIntExit();                                                /* Tell uC/OS-II that we are leaving the ISR            */
}
