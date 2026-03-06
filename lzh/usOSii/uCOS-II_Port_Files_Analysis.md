# uC/OS-II Port Files Analysis (ARMv7-M / Cortex-M4)

本文档详细分析了 uC/OS-II 移植到 ARM Cortex-M4 (ARMv7-M 架构) 时的三个关键文件。这些文件位于 `Ports/ARM-Cortex-M/ARMv7-M/ARM/` 目录下（针对 Keil ARMCC 编译器）。

## 1. `os_cpu.h` - 处理器相关头文件

这个文件定义了与处理器架构相关的常量、宏和数据类型，是内核与硬件之间的“适配层”。

### 1.1 数据类型定义 (Data Types)
uC/OS-II 使用自定义的数据类型名来保证移植性。在 Cortex-M4 上：
*   **整型**: 定义了 `INT8U` (8位), `INT16U` (16位), `INT32U` (32位) 等。
*   **堆栈类型 (`OS_STK`)**: 定义为 `unsigned int` (32位)。因为 ARM Cortex-M 的堆栈必须是 4 字节对齐的。
*   **状态寄存器 (`OS_CPU_SR`)**: 定义为 32 位，用于保存 CPSR/xPSR 或 BASEPRI 寄存器的值。

### 1.2 临界区管理 (Critical Section)
uC/OS-II 需要在访问共享资源或内核结构时关闭中断。Cortex-M4 提供了几种关中断的方法，这里使用的是 **Method #3**。

*   **Method #3**: 保存中断状态到局部变量，然后关中断；退出时恢复之前的状态。
*   **实现方式**: 利用 `BASEPRI` 寄存器。
    *   **`OS_ENTER_CRITICAL()`**: 调用 `OS_CPU_SR_Save()`。它会将当前的 `BASEPRI` 保存到 `cpu_sr` 变量中，然后将 `BASEPRI` 设置为某个阈值（由 `CPU_CFG_KA_IPL_BOUNDARY` 定义），从而屏蔽掉优先级低于该阈值的中断（注意：ARM 中优先级数值越大，优先级越低）。这实现了“内核感知 (Kernel Aware)”的中断屏蔽，允许更高优先级（非内核感知）的中断继续响应。
    *   **`OS_EXIT_CRITICAL()`**: 调用 `OS_CPU_SR_Restore(cpu_sr)`，将 `BASEPRI` 恢复为之前保存的值。

### 1.3 栈增长方向
*   **`OS_STK_GROWTH`**: 定义为 `1`，表示堆栈从高地址向低地址增长（High to Low），这是 ARM 架构的标准行为。

### 1.4 任务切换宏
*   **`OS_TASK_SW()`**: 定义为 `OSCtxSw()`。当内核需要进行任务切换时（例如在 `OS_Sched` 中），会调用这个宏。

---

## 2. `os_cpu_a.asm` - 汇编底层实现

这是移植中最核心的部分，负责处理寄存器层面的**上下文切换**。

### 2.1 `OSStartHighRdy` - 启动多任务
这个函数由 `OSStart()` 调用，且只执行一次，用于启动系统中的第一个任务。

**流程**:
1.  **设置 PendSV 优先级**: 将 PendSV 异常设置为最低优先级 (0xFF)。这是为了确保上下文切换（由 PendSV 处理）只在没有其他中断处理时发生，保护中断响应实时性。
2.  **设置 PSP 为 0**: 初始化进程堆栈指针 (PSP) 为 0。
3.  **切换到 MSP**: 确保内核使用主堆栈指针 (MSP)。
4.  **设置 `OSRunning = 1`**: 标记系统已运行。
5.  **恢复第一个任务的上下文**:
    *   从 `OSTCBHighRdy` 获取最高优先级任务的 TCB。
    *   从 TCB 中获取该任务的堆栈指针 (SP)。
    *   将 SP 加载到 PSP。
    *   **模拟中断返回**: 从任务栈中手动弹出 `R4-R11` 和 `LR` (R0-R3, R12, PC, xPSR 会由硬件在异常返回时自动弹出，但这里是第一次启动，实际上是手动构造了异常返回栈帧)。
    *   执行 `BX LR` (或者类似指令) 跳转到任务代码。

### 2.2 `OSCtxSw` 和 `OSIntCtxSw` - 触发任务切换
*   **`OSCtxSw`**: 任务级切换。
*   **`OSIntCtxSw`**: 中断级切换。
*   **实现**: 它们非常简单，只是向 NVIC 的 `INT_CTRL` 寄存器写入 `PendSVSET` 位，**触发 PendSV 异常**。真正的切换逻辑都在 `PendSV_Handler` 中。

### 2.3 `OS_CPU_PendSVHandler` - 上下文切换的核心
这是 uC/OS-II 在 Cortex-M 上实现任务切换的关键中断服务程序。

**核心逻辑**:
1.  **关中断 (保护临界区)**: 设置 `BASEPRI` 屏蔽内核中断。
2.  **保存当前任务上下文**:
    *   获取当前 PSP (当前任务的堆栈指针)。
    *   **硬件自动保存**: xPSR, PC, LR, R12, R0-R3 已经在进入异常时由硬件自动压入 PSP 指向的堆栈了。
    *   **软件手动保存**: 使用 `STMDB` 指令将 `R4-R11` 和 `LR` (EXC_RETURN) 压入 PSP。
    *   将最终的 PSP 值保存到当前任务 TCB 的 `OSTCBStkPtr` 中 (`OSTCBCur->OSTCBStkPtr = SP`)。
3.  **调用 Hook**: `OSTaskSwHook()`。
4.  **切换 TCB 指针**:
    *   `OSPrioCur = OSPrioHighRdy`
    *   `OSTCBCur = OSTCBHighRdy`
5.  **恢复新任务上下文**:
    *   从新任务 TCB 中读取堆栈指针 (`SP = OSTCBHighRdy->OSTCBStkPtr`)。
    *   **软件手动恢复**: 从新堆栈中弹出 `R4-R11` 和 `LR`。
    *   更新 PSP (`MSR PSP, R0`)。
6.  **开中断**: 恢复 `BASEPRI`。
7.  **异常返回**: 执行 `BX LR`。硬件会自动从 PSP 弹出剩余的寄存器 (R0-R3, PC, xPSR)，从而跳转到新任务继续执行。

### 2.4 `OS_CPU_SR_Save` / `Restore`
这两个函数配合 C 语言中的 `OS_ENTER_CRITICAL()` 使用。
*   `Save`: 读取当前 `BASEPRI` -> 保存到 R0 (返回值) -> 设置新的 `BASEPRI` (关中断)。
*   `Restore`: 将 R0 (参数) 的值写回 `BASEPRI` (恢复中断状态)。

---

## 3. `os_dbg.c` - 调试辅助文件

这个文件包含了一系列 `const` 常量，它们并没有被内核代码直接逻辑使用，而是专门为**调试器 (Debuggers)** 准备的。

### 3.1 作用
像 μC/Probe 或者 IDE (Keil/IAR) 的 RTOS 插件需要知道目标板上 uC/OS-II 的内部状态，例如：
*   `OS_TCB` 结构体的大小是多少？
*   `OSEventTbl` 数组在哪里？大小是多少？
*   当前有哪些任务？优先级是多少？

由于不同的编译器优化和配置 (`os_cfg.h`) 会导致这些结构体的大小和内存布局发生变化，调试器不能硬编码这些偏移量。

### 3.2 实现原理
`os_dbg.c` 定义了大量的全局常量，例如：
*   `OSDataSize`: 整个 uC/OS-II 全局数据区的大小。
*   `OSTCBSize`: `OS_TCB` 结构体的大小。
*   `OSVersionNbr`: 内核版本号。

调试器可以通过符号表（Symbol Table, .axf/.elf 文件）找到这些变量的地址，读取它们的值，从而动态计算出内核数据的布局，正确地显示任务列表、堆栈使用率等信息。

### 3.3 `OSDebugInit()`
这是一个“假”初始化函数。它的唯一目的是在代码中引用上述的那些 `const` 变量。
**为什么？** 智能的编译器链接器会发现这些 `const` 变量在程序其他地方从未被读取（因为只有外部调试器会读它们），从而把它们优化掉（剔除出最终二进制文件）。
通过在 `OSDebugInit()` 中把这些变量赋值给一个 `void *ptemp` 指针，编译器就会认为这些变量是“有用”的，从而保留它们。

---

## 4. `os_cpu_c.c` - C 语言底层实现

这个文件实现了与处理器相关的 C 函数，主要包括任务堆栈初始化和系统时钟滴答 (SysTick) 的管理。

### 4.1 `OSTaskStkInit` - 初始化任务堆栈
当调用 `OSTaskCreate` 或 `OSTaskCreateExt` 创建任务时，内核会调用此函数来初始化该任务的堆栈，使其看起来像刚刚发生了一次中断一样。

**堆栈帧结构 (从高地址到低地址)**:
1.  **硬件自动保存部分**:
    *   `xPSR`: 程序状态寄存器 (通常设为 `0x01000000`，表示 Thumb 状态)。
    *   `PC`: 任务入口地址 (`task`)。
    *   `LR`: 返回地址 (通常设为 `OS_TaskReturn`，用于捕获任务意外返回)。
    *   `R12`, `R3`, `R2`, `R1`, `R0`: 参数寄存器 (R0 存放 `p_arg`)。
2.  **软件手动保存部分**:
    *   `EXEC_RETURN`: 异常返回码 (如 `0xFFFFFFFD`)，指示返回线程模式并使用 PSP。
    *   `R11` - `R4`: 通用寄存器。
3.  **FPU 寄存器 (如果启用)**:
    *   如果启用了硬件浮点单元，还会保存 `S0-S31` 和 `FPSCR`。

**作用**:
确保当任务第一次被调度运行时，`PendSV_Handler` 执行出栈操作后，CPU 能正确地跳转到任务入口函数，并且寄存器（特别是参数 R0）已经准备好。

### 4.2 Hook 函数 (钩子函数)
包含了一系列空函数（或调用 `App_` 开头的函数），允许用户在特定时间点插入自定义代码：
#### 完善 App_TaskCreateHook 的最佳方式是利用它来增强系统的 可观测性，**在操作系统层面无作用**
*   `OSTaskCreateHook`: 任务创建时调用。
*   `OSTaskDelHook`: 任务删除时调用。
*   `OSTaskSwHook`: **任务切换时调用**。如果启用了 FPU，这里会保存/恢复 FPU 寄存器。
*   `OSTimeTickHook`: 每个系统滴答调用。

### 4.3 SysTick 管理
uC/OS-II 需要一个周期性的时钟中断来实现延时和超时功能。在 Cortex-M 上，通常使用 SysTick 定时器。

*   **`OS_CPU_SysTickInit(cnts)` / `OS_CPU_SysTickInitFreq(freq)`**:
    *   计算重装载值 (`OS_CPU_CM_SYST_RVR`)。
    *   设置 SysTick 中断优先级 (`OS_CPU_CM_SCB_SHPRI3`)。通常设为最低或与 `BASEPRI` 边界相同。
    *   启用定时器和中断。
*   **`OS_CPU_SysTickHandler()`**: SysTick 的中断服务程序。
    *   `OS_ENTER_CRITICAL()` / `OS_EXIT_CRITICAL()`: 保护临界区。
    *   `OSIntEnter()`: 通知内核进入中断。
    *   `OSTimeTick()`: **调用内核的时钟节拍处理函数** (处理任务延时、时间片轮转等)。
    *   `OSIntExit()`: 退出中断，可能会触发任务调度。
