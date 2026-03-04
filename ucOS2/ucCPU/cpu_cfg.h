/*
*********************************************************************************************************
*                                               uC/CPU
*                                        CPU CONFIGURATION FILE
*
* Filename : cpu_cfg.h
*********************************************************************************************************
*/

#ifndef  CPU_CFG_H
#define  CPU_CFG_H

/*
*********************************************************************************************************
*                                      CPU / NVIC CONFIGURATION
*
* Note(s) : (1) STM32F401 (Cortex-M4) implements 4 NVIC priority bits.
*           (2) CPU_CFG_KA_IPL_BOUNDARY must be > 0 for this port.
*               A value of 1u is a conservative minimal setting to get the project building.
*********************************************************************************************************
*/

#define  CPU_CFG_KA_IPL_BOUNDARY        1u
#define  CPU_CFG_NVIC_PRIO_BITS         4u


/*
*********************************************************************************************************
*                                          CPU NAME CONFIG
*
* Note(s) : (1) Enable CPU host name support.
*           (2) CPU_CFG_NAME_SIZE is the size of the internal CPU_Name[] buffer.
*********************************************************************************************************
*/

#define  CPU_CFG_NAME_EN                1u
#define  CPU_CFG_NAME_SIZE              32u


/*
*********************************************************************************************************
*                                        TIMESTAMP CONFIG
*
* Note(s) : (1) Disable timestamp features for now to simplify the build.
*           (2) If later needed, these can be enabled and supported with a timer source.
*********************************************************************************************************
*/

#define  CPU_CFG_TS_32_EN               0u
#define  CPU_CFG_TS_64_EN               0u


/*
*********************************************************************************************************
*                                OPTIONAL INTERRUPT DISABLE MEASUREMENT
*
* Note(s) : Leave undefined if not used.
*
* Example :
*            #define CPU_CFG_INT_DIS_MEAS_EN
*********************************************************************************************************
*/

/* #define CPU_CFG_INT_DIS_MEAS_EN */


#endif
