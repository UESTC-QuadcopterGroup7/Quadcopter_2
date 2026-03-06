# uC/OS-II 源码详细解析

uC/OS-II (Micro-Controller Operating System Version 2) 是一个可移植、可固化、可裁剪的抢占式实时多任务操作系统内核。本文档将详细解析其核心源码结构及关键机制。

## 1. 源码目录结构

在 `ucOSii-raw` 文件夹中，通常包含以下关键部分：

*   **Source/** (核心代码): 包含与处理器无关的代码，是内核的主体。
    *   `os_core.c`: 核心功能（调度、初始化、事件控制块管理等）。
    *   `os_task.c`: 任务管理（创建、删除、挂起、恢复）。
    *   `os_flag.c`: 事件标志组管理。
    *   `os_mbox.c`: 消息邮箱管理。
    *   `os_mem.c`: 内存管理（固定大小内存块）。
    *   `os_mutex.c`: 互斥型信号量管理。
    *   `os_q.c`: 消息队列管理。
    *   `os_sem.c`: 信号量管理。
    *   `os_time.c`: 时间管理（延时、系统时间获取）。
    *   `os_tmr.c`: 软件定时器管理。
    *   `ucos_ii.h`: 包含所有头文件和系统配置宏定义。

*   **Ports/** (移植代码): 包含与处理器相关的代码。
    *   `os_cpu.h`: 定义数据类型、处理器相关宏（如关中断/开中断）、堆栈增长方向等。
    *   `os_cpu_c.c`: C语言实现的底层钩子函数（如堆栈初始化 `OSTaskStkInit`）。
    *   `os_cpu_a.s` (或 .asm): 汇编实现的底层函数（如上下文切换 `OSCtxSw`, 中断级切换 `OSIntCtxSw`, 启动 `OSStartHighRdy`）。

*   **Cfg/** (配置代码):
    *   `os_cfg.h`: 裁剪和配置内核功能（如最大任务数、是否使能某个功能模块）。
    *   `includes.h`: 项目的主头文件。

---

## 2. 核心机制解析

### 2.1 任务管理 (Task Management)

uC/OS-II 是基于任务的。每个任务都是一个无限循环的函数。

*   **任务控制块 (OS_TCB)**: 每个任务都有一个 TCB，用于保存任务的状态、优先级、堆栈指针等信息。所有 TCB 存储在 `OSTCBTbl[]` 数组中，或通过双向链表管理。
*   **任务创建 (`OSTaskCreate`)**:
    1.  检查优先级是否合法且未被占用。
    2.  初始化任务堆栈 (`OSTaskStkInit`)，模拟发生中断后的堆栈结构，以便首次调度时能像从中断返回一样“恢复”到任务入口。
    3.  从空闲 TCB 链表中获取一个 TCB，并初始化。
    4.  将任务放入就绪表。
    5.  如果系统已运行，触发调度。

### 2.2 调度算法 (Scheduler)

uC/OS-II 采用**基于优先级的抢占式调度**。总是运行处于就绪态的优先级最高的任务。

*   **就绪表 (`OSRdyTbl` & `OSRdyGrp`)**:
    *   使用位图 (Bitmap) 算法来快速查找最高优先级。
    *   `OSRdyGrp`: 每一位代表一组（8个）优先级中是否有任务就绪。
    *   `OSRdyTbl[]`: 数组的每个元素代表具体的8个优先级。
*   **最高优先级查找**:
    *   利用 `OSUnMapTbl[]` 查表法，可以在 O(1) 的固定时间内找到最高优先级任务，保证了系统的实时性和确定性。
    *   算法核心：`y = OSUnMapTbl[OSRdyGrp]; x = OSUnMapTbl[OSRdyTbl[y]]; prio = (y << 3) + x;`
*   **任务切换**:
    *   `OS_Sched()`: 任务级调度。查找最高优先级任务，如果不是当前任务，则调用 `OS_TASK_SW()` (宏调用软中断或陷阱指令) 触发上下文切换。
    *   `OSIntExit()`: 中断级调度。在中断服务程序 (ISR) 结束时调用，检查是否有更高优先级任务被中断唤醒。

### 2.3 中断处理 (Interrupt Handling)

*   **中断服务程序 (ISR) 结构**:
    ```c
    void ISR_Handler(void) {
        Save_Context();      // 保存寄存器 (汇编)
        OSIntNesting++;      // 记录中断嵌套层数 (或调用 OSIntEnter())
        if (OSIntNesting == 1) {
            OSTCBCur->OSTCBStkPtr = SP; // 保存当前任务堆栈指针
        }
        Clear_Interrupt();   // 清除中断源
        OSIntExit();         // 退出中断，触发可能的调度
        Restore_Context();   // 恢复寄存器 (汇编)
    }
    ```
*   **关键点**: uC/OS-II 允许中断嵌套。只有在最外层中断退出时 (`OSIntExit`) 才会尝试任务切换。

### 2.4 时间管理 (Time Management)

*   **系统节拍 (Tick)**: 硬件定时器产生周期性中断，调用 `OSTimeTick()`。
*   **`OSTimeTick()`**:
    *   遍历所有 TCB。
    *   如果任务的 `OSTCBDly` (延时计数器) 非零，则递减。
    *   如果减为0，将任务设为就绪态。
*   **`OSTimeDly(ticks)`**: 任务调用此函数主动放弃 CPU，将自己挂起指定 tick 数，并触发调度。

### 2.5 任务间通信 (IPC)

所有 IPC 机制（信号量、邮箱、队列）都基于**事件控制块 (OS_EVENT)**。

*   **等待机制**: 当任务请求资源（如 `OSSemPend`）且资源不可用时：
    1.  任务状态被标记为挂起。
    2.  任务被从就绪表中移除。
    3.  任务被加入到该事件 (`OS_EVENT`) 的等待列表中。
    4.  触发调度。
*   **唤醒机制**: 当资源被释放（如 `OSSemPost`）：
    1.  检查等待列表是否有任务。
    2.  如果有，取出优先级最高的任务。
    3.  将其放入就绪表。
    4.  触发调度。

---

## 3. 关键数据结构图解

### 就绪表查找逻辑
```text
OSRdyGrp (8 bits)
  |
  +--> [1] bit set? -> Check OSRdyTbl[1]
        |
        +--> OSRdyTbl[1] (8 bits)
              |
              +--> Find first set bit -> Task Priority Found!
```

### 任务控制块 (简略)
```c
typedef struct os_tcb {
    OS_STK          *OSTCBStkPtr;      // 当前堆栈指针 (最重要)
    struct os_tcb   *OSTCBNext;        // TCB 链表
    struct os_tcb   *OSTCBPrev;
    INT16U           OSTCBDly;         // 延时计数值
    INT8U            OSTCBStat;        // 任务状态 (就绪、挂起、等待信号量等)
    INT8U            OSTCBPrio;        // 任务优先级
    // ... 其他扩展项
} OS_TCB;
```

---

## 4. 学习建议

1.  **从 `OS_Core.c` 开始**: 理解 `OSInit` (初始化) 和 `OSStart` (启动多任务) 的流程。
2.  **深入 `OS_Sched`**: 掌握位图算法查找最高优先级的原理，这是 uC/OS-II 高效的核心。
3.  **阅读 `Port` 代码**: 尤其是 `os_cpu_a.s` 中的 `OSCtxSw`，理解寄存器是如何被保存和恢复到堆栈中的，这是理解“任务切换”本质的关键。
4.  **调试**: 在 IDE 中单步调试 `OSStartHighRdy`，观察堆栈指针的变化。

---

## 5. STM32F401RET6 移植所需文件清单

将 uC/OS-II 移植到 STM32F401RET6 (Cortex-M4 内核) 时，你需要从源码包中提取以下文件。请保持原有的目录结构或根据你的工程结构进行整理。

### 5.1 核心源码 (Kernel Source)
**路径**: `ucOSii-raw/Source/`
> 这些文件是操作系统的核心，与硬件无关，必须全部保留。

*   `os_core.c`
*   `os_flag.c`
*   `os_mbox.c`
*   `os_mem.c`
*   `os_mutex.c`
*   `os_q.c`
*   `os_sem.c`
*   `os_task.c`
*   `os_time.c`
*   `os_tmr.c`
*   `ucos_ii.h`

### 5.2 移植文件 (Port Files)
**路径**: `ucOSii-raw/Ports/ARM-Cortex-M/ARMv7-M/`
> STM32F401 属于 ARM Cortex-M4 内核，采用 ARMv7-M 架构。你需要根据你使用的编译器（IDE）选择对应的子文件夹。

**公共文件**:
*   `os_cpu_c.c` (位于 `ARMv7-M/` 根目录下)

**编译器相关文件 (三选一)**:

1.  **如果你使用 Keil MDK (ARMCC/ArmClang)**:
    *   路径: `ARMv7-M/ARM/`
    *   文件: `os_cpu.h`, `os_cpu_a.asm`, `os_dbg.c`

2.  **如果你使用 STM32CubeIDE / GCC**:
    *   路径: `ARMv7-M/GNU/`
    *   文件: `os_cpu.h`, `os_cpu_a.S`, `os_dbg.c`

3.  **如果你使用 IAR EWARM**:
    *   路径: `ARMv7-M/IAR/`
    *   文件: `os_cpu.h`, `os_cpu_a.asm`, `os_dbg.c`

### 5.3 配置文件 (Configuration)
**路径**: `ucOSii-raw/Cfg/Template/`
> 这些文件用于配置系统功能（如裁剪不需要的模块）和设置系统节拍。

*   `os_cfg.h` (必须，需要根据项目需求修改)
*   `app_cfg.h` (可选，用于应用层配置)
*   `app_hooks.c` (可选，用于定义空闲任务钩子等)

### 5.4 移植总结
在你的 STM32 工程中，你的文件结构看起来应该像这样：

```text
Project_Root/
├── Core/ (STM32 HAL/LL 库及 main.c)
├── uCOS-II/
│   ├── Source/      <-- 放入 5.1 中的所有 .c 和 .h
│   ├── Ports/       <-- 放入 5.2 中的 os_cpu_c.c 和编译器特定的 .asm/.h
│   └── Config/      <-- 放入 5.3 中的 os_cfg.h (及 includes.h)
```

**注意**:
1.  **SysTick 配置**: 你需要在 STM32 的 SysTick 中断服务函数中调用 `OSTimeTick()`。
2.  **PendSV 配置**: 确保启动文件 (`startup_stm32f401xe.s`) 中的 `PendSV_Handler` 指向 `OS_CPU_PendSVHandler` (或者在 `os_cpu_a.asm` 中修改函数名为 `PendSV_Handler`)。
