#include <stdint.h>
#include "SEGGER_SYSVIEW.h"
#include "system_stm32f4xx.h"

/*
 * SystemView configuration for the quadcopter uC/OS-II port.
 * Build this file together with SEGGER_SYSVIEW_uCOSII.c when
 * uC/OS-II trace hooks are enabled.
 */
extern const SEGGER_SYSVIEW_OS_API SYSVIEW_X_OS_TraceAPI;

#define SYSVIEW_APP_NAME      "Quadcopter_uCOSII"
#define SYSVIEW_DEVICE_NAME   "STM32F401RETx"
#define SYSVIEW_RAM_BASE      (0x20000000u)

static void _cbSendSystemDesc(void) {
  SEGGER_SYSVIEW_SendSysDesc("N=" SYSVIEW_APP_NAME ",D=" SYSVIEW_DEVICE_NAME ",O=uC/OS-II");
  SEGGER_SYSVIEW_SendSysDesc("I#2=NMI");
  SEGGER_SYSVIEW_SendSysDesc("I#3=HardFault");
  SEGGER_SYSVIEW_SendSysDesc("I#4=MemManage");
  SEGGER_SYSVIEW_SendSysDesc("I#5=BusFault");
  SEGGER_SYSVIEW_SendSysDesc("I#6=UsageFault");
  SEGGER_SYSVIEW_SendSysDesc("I#11=SVCall");
  SEGGER_SYSVIEW_SendSysDesc("I#12=DebugMon");
  SEGGER_SYSVIEW_SendSysDesc("I#14=PendSV");
  SEGGER_SYSVIEW_SendSysDesc("I#15=SysTick");
  SEGGER_SYSVIEW_SendSysDesc("I#44=TIM2");
  SEGGER_SYSVIEW_SendSysDesc("I#46=TIM4");
}

void SEGGER_SYSVIEW_Conf(void) {
  SEGGER_SYSVIEW_Init(SystemCoreClock, SystemCoreClock, &SYSVIEW_X_OS_TraceAPI, _cbSendSystemDesc);
  SEGGER_SYSVIEW_SetRAMBase(SYSVIEW_RAM_BASE);
}
