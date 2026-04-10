.syntax unified
.cpu cortex-m4
.thumb

.extern main
.extern _sidata
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss
.extern _estack

.section .isr_vector, "a", %progbits
.balign 512
.global g_pfnVectors
.type g_pfnVectors, %object
g_pfnVectors:
    .word _estack
    .word Reset_Handler
    .word Default_Handler
    .word Default_Handler
    .word Default_Handler
    .word Default_Handler
    .word Default_Handler
    .word 0
    .word 0
    .word 0
    .word 0
    .word Default_Handler
    .word Default_Handler
    .word 0
    .word Default_Handler
    .word Default_Handler
    .rept 85
    .word Default_Handler
    .endr
.size g_pfnVectors, . - g_pfnVectors

.section .text.Reset_Handler, "ax", %progbits
.thumb_func
.global Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    bl SystemInit

    ldr r0, =_sidata
    ldr r1, =_sdata
    ldr r2, =_edata

.Lcopy_data:
    cmp r1, r2
    bcs .Lzero_bss
    ldr r3, [r0], #4
    str r3, [r1], #4
    b .Lcopy_data

.Lzero_bss:
    ldr r1, =_sbss
    ldr r2, =_ebss
    movs r3, #0

.Lbss_loop:
    cmp r1, r2
    bcs .Lcall_main
    str r3, [r1], #4
    b .Lbss_loop

.Lcall_main:
    bl main

.Lhang:
    b .Lhang
.size Reset_Handler, . - Reset_Handler

.section .text.SystemInit, "ax", %progbits
.thumb_func
.weak SystemInit
.type SystemInit, %function
SystemInit:
    bx lr
.size SystemInit, . - SystemInit

.section .text.Default_Handler, "ax", %progbits
.thumb_func
.global Default_Handler
.type Default_Handler, %function
Default_Handler:
    b Default_Handler
.size Default_Handler, . - Default_Handler
