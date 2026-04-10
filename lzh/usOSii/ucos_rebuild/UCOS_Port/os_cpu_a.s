    EXTERN      OSRunning
    EXTERN      OSPrioCur
    EXTERN      OSPrioHighRdy
    EXTERN      OSTCBCur
    EXTERN      OSTCBHighRdy
    EXTERN      OSIntNesting
    EXTERN      OSIntExit
    EXTERN      OSTaskSwHook

    EXPORT      OS_CPU_SR_Save 
    EXPORT      OS_CPU_SR_Restore
    EXPORT      OSStartHighRdy
    EXPORT      OSCtxSw
    EXPORT      OSIntCtxSw
    EXPORT      OS_CPU_PendSVHandler

NVIC_INT_CTRL       EQU		0xE000ED04
NVIC_SYSPRI14       EQU     0xE000ED22
NVIC_PENDSV_PRI     EQU     0xFF
NVIC_PENDSVSET      EQU     0x10000000

    AREA |.text|, CODE, READONLY, ALIGN = 2
    THUMB
    REQUIRE8
    PRESERVE8

OS_CPU_SR_Save
            MRS     R0,PRIMASK
            CPSID   I
            BX      LR

OS_CPU_SR_Restore
            MSR     PRIMASK,R0
            BX      LR

OSStartHighRdy
            ; set pendsv prio
            LDR     R0,     =NVIC_SYSPRI14
            LDR     R1,     =NVIC_PENDSV_PRI
            STR     R1,     [R0]

            ;clear psp
            MOV     R0,     #0
            MSR     PSP,    R0

            ;set state osrunning
            LDR     R0,     =OSRunning
            MOV     R1,     #1
            STRB    R1,     [R0]

            ;enable pendsv
            LDR     R0,     =NVIC_INT_CTRL
            LDR     R1,     =NVIC_PENDSVSET
            STR     R1,     [R0]

            ;open interrupt
            CPSIE   I

            ;don't need to 'BX LR', because after enable pendsv, 
            ;the programme will jump to OS_CPU_PendSVHandler

OSCtxSw
OSIntCtxSw
            ;enable pendsv
            LDR     R0,     =NVIC_INT_CTRL
            LDR     R1,     =NVIC_PENDSVSET
            STR     R1,     [R0]
            BX      LR

OS_CPU_PendSVHandler
            ;close interrupt
            CPSID   I

            ;check psp
            MRS     R0,     PSP
            CBZ     R0,     OS_CPU_First_PendSVHandler

            ;save context
            STMFD   R0!,    {R4-R11}

            ;store sp
            LDR     R1,     =OSTCBCur
            LDR     R1,     [R1]
            STR     R0,     [R1]

OS_CPU_First_PendSVHandler
            ;taskswhook
            PUSH    {LR}
            LDR     R0,     =OSTaskSwHook
            BLX     R0
            POP     {LR}

            ;OSTCBCur = OSTCBHighRdy
            LDR     R0,     =OSTCBHighRdy
            LDR     R1,     =OSTCBCur
            LDR     R0,     [R0]
            STR     R0,     [R1]

            ;OSPrioCur = OSPrioHighRdy
            LDR     R0,     =OSPrioHighRdy
            LDR     R1,     =OSPrioCur
            LDRB    R0,     [R0]
            STRB    R0,     [R1]

            ;get stkptr of OSTCBHighRdy
            LDR     R0,     =OSTCBHighRdy
            LDR     R0,     [R0]
            LDR     R0,     [R0]
            
            ;pop stack
            LDMFD   R0!,    {R4-R11}
            MSR     PSP,    R0

            ;set exception return, ensuring using PSP
            ORR     LR,     LR,     #0x04
            ;异常返回时，LR 包含特殊值（EXC_RETURN）：
            ;0xFFFFFFF9: 返回 Thread 模式，使用 MSP  错误！！
            ;0xFFFFFFFD: 返回 Thread 模式，使用 PSP ← 任务模式
            ;Bit2 = 0: MSP
            ;Bit2 = 1: PSP
            ;ORR LR, LR, #0x04 → 设置 Bit2 = 1 → 使用 PSP

            ;open interrupt
            CPSIE   I

            BX      LR

            NOP

            END

