# SysTick 到达后发生了什么？

## 系统参数

| 参数 | 值 | 含义 |
|------|-----|---------|
| `OS_TICKS_PER_SEC` | 1000 | 每 1ms 产生一次 SysTick |
| `OS_LOWEST_PRIO` | 63 | 共 64 个优先级 |
| `OS_TASK_IDLE_PRIO` | 63 | Idle 任务优先级最低 |
| `AppTaskSensor` 优先度 | 6 | 每 5ms 运行一次 |
| `AppTaskDebug` 优先度 | 10 | 每 1s 运行一次 |

## 涉及的源文件

| 文件 | 角色 |
|------|------|
| `Src/stm32f4xx_it.c` | SysTick_Handler (最外层 ISR) |
| `Port/os_cpu_c.c` | OS_CPU_SysTickHandler (uC/OS-II 入口) |
| `Source/os_core.c` | OSTimeTick, OSIntExit, OS_Sched, OS_SchedNew |
| `Source/os_time.c` | OSTimeDly, OSTimeDlyHMSM |
| `Port/os_cpu_a.asm` | OS_CPU_PendSVHandler (上下文切换汇编) |
| `SEGGER/uCOS-II/os_trace_events.h` | SystemView 追踪宏 |
| `MyLib/ReadPeripherals.c` | ReadPeripherals_Process (传感器读取) |
| `Src/main.c` | AppTaskSensor, AppTaskDebug |

---

## 完整执行流程

假设当前场景：**AppTaskSensor 刚调用完 `OSTimeDlyHMSM(0,0,0,5)` 进入延时，系统正在执行 Idle 任务。** 此时 `AppTaskSensor.OSTCBDly = 5`。

### 阶段 1：硬件触发 SysTick

```
Cortex-M4 NVIC 每 1ms 触发一次 SysTick 异常 (IRQ #15)
优先级由 OS_CPU_SysTickInit 在启动时配置
```

### 阶段 2：SysTick_Handler (`stm32f4xx_it.c:12`)

这是最外层的 C ISR，由启动文件中的中断向量表直接调用：

```c
void SysTick_Handler(void)
{
    HAL_IncTick();                    // ① 递增 HAL 滴答计数器 (uwTick++)
                                      //    保证 HAL_Delay/HAL_GetTick 在 RTOS 下仍能工作

    if (OSRunning == OS_TRUE) {       // ② 如果 RTOS 已启动
        OS_CPU_SysTickHandler();      //    跳转到 uC/OS-II 内部处理
    }
}
```

**SystemView 可见内容：** 尚无——SysTick ISR 的进入/退出由 uC/OS-II 在内部记录。

### 阶段 3：OS_CPU_SysTickHandler (`Port/os_cpu_c.c:650`)

```c
void OS_CPU_SysTickHandler(void)
{
    OS_ENTER_CRITICAL();             // ① 关中断 (BASEPRI)
    OSIntEnter();                    // ② OSIntNesting++
    OS_EXIT_CRITICAL();              // ③ 恢复 BASEPRI

    OSTimeTick();                    // ④ 内核滴答处理（核心逻辑）

    OSIntExit();                     // ⑤ 中断退出 + 可能的上下文切换
}
```

#### ③ `OSIntEnter()` 的作用

```c
// os_core.c:676
void OSIntEnter(void) {
    OSIntNesting++;                  // 中断嵌套计数 +1
    OS_TRACE_ISR_ENTER();            // → SEGGER_SYSVIEW_RecordEnterISR()
}                                    //   ✅ SystemView 显示 "SysTick ISR 进入"
```

#### ④ `OSTimeTick()` 的作用（核心逻辑）

```c
// os_core.c:937
void OSTimeTick(void)
{
    OSTimeTickHook();                // 用户钩子（本项目中为空或调用 App_TimeTickHook）
    OSTime++;                        // 全局滴答计数器 +1
    OS_TRACE_TICK_INCREMENT(OSTime); // ✅ SystemView 显示滴答递增事件

    // 遍历所有 TCB，递减每个任务的延时计数器
    ptcb = OSTCBList;
    while (ptcb->OSTCBPrio != OS_TASK_IDLE_PRIO) {
        if (ptcb->OSTCBDly != 0) {
            ptcb->OSTCBDly--;                     // 延时计数器 -1
            if (ptcb->OSTCBDly == 0) {            // 延时到期！
                if (任务被挂起) {
                    ptcb->OSTCBStat &= ~OS_STAT_PEND_ANY;  // 清除挂起标志
                    ptcb->OSTCBStatPend = OS_STAT_PEND_TO;  // 标记为超时
                } else {
                    ptcb->OSTCBStatPend = OS_STAT_PEND_OK;
                }
                if (!(ptcb->OSTCBStat & OS_STAT_SUSPEND)) {
                    OSRdyGrp  |= ptcb->OSTCBBitY;   // ① 将任务放回就绪表
                    OSRdyTbl[...] |= ptcb->OSTCBBitX;
                    OS_TRACE_TASK_READY(ptcb);       // ✅ SystemView 显示 "任务就绪"
                }
            }
        }
        ptcb = ptcb->OSTCBNext;                    // 下一个 TCB
    }
}
```

在你的场景中 (AppTaskSensor 的 `OSTCBDly == 5`，每次滴答递减)：

| Tick | AppTaskSensor.OSTCBDly | 状态 |
|------|------------------------|------|
| N   | 5 (刚进入延时) | 不在就绪表中，执行 Idle |
| N+1 | 4 | 仍在延时 |
| N+2 | 3 | 仍在延时 |
| N+3 | 2 | 仍在延时 |
| N+4 | 1 | 仍在延时 |
| N+5 | 0 → **到期！** | **重新加入就绪表，成为最高就绪任务** |

#### ⑤ `OSIntExit()` 的作用 (`os_core.c:693`)

```c
void OSIntExit(void)
{
    OSIntNesting--;                    // 中断嵌套计数 -1

    if (OSIntNesting == 0) {           // 所有嵌套 ISR 都已完成
        if (OSLockNesting == 0) {      // 调度器未锁定
            OS_SchedNew();             // ① 从就绪表中找出最高优先级任务
            OSTCBHighRdy = OSTCBPrioTbl[OSPrioHighRdy];

            if (OSPrioHighRdy != OSPrioCur) {  // ② 如果需要切换
                OS_TRACE_ISR_EXIT_TO_SCHEDULER();  // ✅ SystemView 显示 ISR 退出并调度
                OSIntCtxSw();             // ③ 触发上下文切换 → 进入阶段 4
            } else {
                OS_TRACE_ISR_EXIT();      // ✅ SystemView 显示 ISR 退出（无需切换）
            }
        }
    }
}
```

关键判断：`OSPrioHighRdy != OSPrioCur`
- Tick N+1~N+4：AppTaskSensor 仍在延时，`OSPrioHighRdy == OS_TASK_IDLE_PRIO == OSPrioCur`，不切换，直接返回 Idle
- **Tick N+5：AppTaskSensor 就绪（prio 6 < 63），`OSPrioHighRdy != OSPrioCur` → 触发上下文切换！**

### 阶段 4：OSIntCtxSw → PendSV (`Port/os_cpu_a.asm:276`)

```asm
OSIntCtxSw
    LDR  R0, =NVIC_INT_CTRL       ; 0xE000ED04 (中断控制状态寄存器)
    LDR  R1, =NVIC_PENDSVSET      ; 0x10000000
    STR  R1, [R0]                 ; 将 PendSV 挂起位置 1
    BX   LR                       ; 返回
```

**这仅仅是将 PendSV 异常标记为 pending，并不立即执行。** PendSV 被配置为最低优先级（`NVIC_PENDSV_PRI = 0xFF`），因此它会等到所有其他中断完成后才执行。

SysTick ISR 返回后，硬件检测到 PendSV pending → **尾链进入 PendSV 处理程序（无需额外的出栈/压栈）**。

### 阶段 5：OS_CPU_PendSVHandler (`Port/os_cpu_a.asm:330`)

这是**真正的上下文切换**发生的地方。SystemView 中不可见（无 `RecordEnterISR` 调用），但**任务切换事件（OnTaskStartExec）在此记录**：

```asm
OS_CPU_PendSVHandler
    CPSID  I                            ; 关中断
    ; 设置 BASEPRI（临界区保护）

    MRS    R0, PSP                      ; ① 获取旧任务的进程栈指针
    STMFD  R0!, {R4-R11, R14}           ; ② 将 R4-R11 和 LR 保存到旧任务栈

    LDR    R5, =OSTCBCur
    LDR    R1, [R5]
    STR    R0, [R1]                     ; ③ OSTCBCur->OSTCBStkPtr = SP（保存栈指针）

    MOV    R4, LR                       ; 保存 EXC_RETURN 值
    BL     OSTaskSwHook                 ; ④ 调用任务切换钩子
    ;                                        ↓
    ;    OSTaskSwHook 内部调用:                ↓
    ;    OS_TRACE_TASK_SWITCHED_IN(OSTCBHighRdy)  ↓
    ;    → SYSVIEW_TaskSwitchedIn()              ↓
    ;    → SEGGER_SYSVIEW_OnTaskStartExec()      ↓
    ;    ✅ SystemView 显示 "AppTaskSensor 开始执行"

    ; ⑤ 更新优先级 + TCB
    OSPrioCur  = OSPrioHighRdy           ; prio 63 → prio 6
    OSTCBCur   = OSTCBHighRdy            ; Idle TCB → AppTaskSensor TCB

    ; ⑥ 恢复新任务的上下文
    LDR    R0, [R2]                     ; R0 = OSTCBHighRdy->OSTCBStkPtr
    LDMFD  R0!, {R4-R11, R14}           ; 从新任务栈恢复 R4-R11, R14
    MSR    PSP, R0                       ; 设置 PSP 为新任务栈

    ; ⑦ 恢复 BASEPRI = 0
    MSR    BASEPRI, #0

    BX     LR                           ; ⑧ 异常返回
    ; 硬件自动恢复 R0-R3, R12, PC, xPSR（Cortex-M 异常返回机制）
```

### 阶段 6：AppTaskSensor 恢复执行

PendSV 处理程序执行 `BX LR`（EXC_RETURN = 0xFFFFFFFD，表示返回 Thread 模式并使用 PSP）：

- 硬件从 PSP 指向的栈中**自动弹出** R0-R3, R12, LR, PC, xPSR
- PC 被加载为 AppTaskSensor 在 `OSTimeDlyHMSM` 中调用 `OS_Sched()` 后的返回地址
- **AppTaskSensor 从 `OSTimeDlyHMSM(0,0,0,5)` 的返回处继续执行**

```c
static void AppTaskSensor(void *p_arg)
{
    while (1) {
        ReadPeripherals_Process();           // ← ① 读取所有传感器
        //   ├─ MPU6050:   200Hz (每次调用)
        //   ├─ HMC5883L:  ~67Hz (每 3 次调用)
        //   └─ MS5611:    5Hz   (非阻塞状态机)
        //
        OSTimeDlyHMSM(0, 0, 0, 5);          // ← ② 再次进入 5ms 延时
        //   ├─ 将 AppTaskSensor 从就绪表移除
        //   ├─ 设置 OSTCBDly = 5
        //   ├─ OS_Sched() → 切换到 Idle 任务
        //   └─ 下一个 Tick 到达时，循环重新开始
    }
}
```

---

## 时间轴总览

```
时间 (ms)  事件
────────  ──────────────────────────────────────────────────────────────
  0.0     SysTick 触发 (IRQ #15)
          ├─ SysTick_Handler: HAL_IncTick()
          ├─ OS_CPU_SysTickHandler:
          │   ├─ OSIntEnter()           ✅ SYSVIEW: SysTick ISR 进入
          │   ├─ OSTimeTick():
          │   │   ├─ OSTime++ (例：tick = 12346)
          │   │   └─ AppTaskSensor.OSTCBDly: 1 → 0 到期！
          │   │       └─ 将 AppTaskSensor 加入就绪表
          │   └─ OSIntExit():
          │       ├─ OS_SchedNew() → OSPrioHighRdy = 6 (AppTaskSensor)
          │       ├─ OSPrioHighRdy != OSPrioCur (6 != 63) → 需要切换
          │       ├─ OS_TRACE_ISR_EXIT_TO_SCHEDULER() ✅
          │       └─ OSIntCtxSw() → 设置 PendSV pending
          └─ 返回
  0.001   硬件尾链进入 PendSV (IRQ #14)
          ├─ 保存 Idle 任务上下文 (R4-R11, R14 → Idle 栈)
          ├─ OSTaskSwHook:
          │   └─ OS_TRACE_TASK_SWITCHED_IN(AppTaskSensor) ✅
          └─ 恢复 AppTaskSensor 上下文 (R4-R11, R14 ← AppTaskSensor 栈)
  0.002   PendSV 异常返回 → AppTaskSensor 恢复执行 ✅ SYSVIEW: 任务运行
          ├─ ReadPeripherals_Process()
          │   ├─ MPU6050_GetData() → 更新 g_MPU6050
          │   ├─ [每 3 次] HMC5883L_GetData() → 更新 g_HMC5883L
          │   └─ [MS5611 状态机] 可能的转换步骤
          └─ OSTimeDlyHMSM(0,0,0,5)
              ├─ OSRdyTbl 移除 AppTaskSensor
              ├─ OSTCBDly = 5
              └─ OS_Sched() → PendSV → 切换到 Idle
  0.007   Idle 任务运行 ✅ SYSVIEW: Idle
          └─ 空循环，等待下一个 SysTick...
  1.0     SysTick 再次触发 → 循环继续
```

---

## SystemView 中实际能看到的

| 可见 | 不可见 |
|------|--------|
| ✅ SysTick ISR 进入 (RecordEnterISR) | ❌ PendSV 异常进入/退出 |
| ✅ OSTimeTick 滴答递增 | ❌ 上下文切换的汇编细节 |
| ✅ 任务就绪事件 (TaskReady) | ❌ HAL_IncTick 调用 |
| ✅ ISR 退出并调度 (RecordExitISRToScheduler) | |
| ✅ 任务切换 (OnTaskStartExec → AppTaskSensor) | |
| ✅ 传感器读取执行时间 | |
| ✅ Idle 任务 (OnIdle) | |

---

## 关键设计要点

### 1. 为什么 PendSV 在 SystemView 中看不到？

`OS_CPU_PendSVHandler` 是**汇编**编写的（`os_cpu_a.asm:330`），它**不调用** `OSIntEnter()`/`OSIntExit()`，因此不会触发 `SEGGER_SYSVIEW_RecordEnterISR()`。这是**刻意为之**：

- PendSV 是上下文切换**机制**，不是应用中断——它不应计入 `OSIntNesting`
- 如果 PendSV 调用 `OSIntEnter()`，会错误地递增中断嵌套计数，破坏内核逻辑
- 有意义的追踪事件（任务切换 `OnTaskStartExec`）已经在 `OSTaskSwHook` 中记录了

### 2. 为什么 SysTick 在 SystemView 中是可见的？

因为 `OS_CPU_SysTickHandler` 调用 `OSIntEnter()` (在 `os_cpu_c.c:658`)，而 `OSIntEnter()` 内部调用 `OS_TRACE_ISR_ENTER()` → `SEGGER_SYSVIEW_RecordEnterISR()`。同样，`OSIntExit()` 调用 `OS_TRACE_ISR_EXIT_TO_SCHEDULER()` 或 `OS_TRACE_ISR_EXIT()`。

### 3. 为什么没有 FreeRTOS 风格的 `xPortSysTickHandler`？

uC/OS-II 的架构不同：
- SysTick **不在** `os_cpu_c.c` 的启动代码中初始化——它由 `AppTaskStart` 中的 `OS_CPU_SysTickInitFreq(SystemCoreClock)` 显式初始化
- SysTick 中断向量在启动文件中指向 `SysTick_Handler`，然后**转发**到 `OS_CPU_SysTickHandler`
- 这种设计使得 HAL 和 uC/OS-II 可以在 SysTick 中共存（`HAL_IncTick` + `OSTimeTick` 都在同一个 ISR 中调用）

### 4. 传感器任务的实际 CPU 占用

| 操作 | 时间 | 说明 |
|------|------|------|
| SysTick ISR (OSTimeTick 扫描) | < 10μs | 遍历少量 TCB |
| PendSV 上下文切换 | ~2μs | 汇编优化 |
| MPU6050_GetData (12 个 I2C 读) | ~5ms | 位脉冲 I2C，每次约 400μs |
| HMC5883L_GetData (每 3 次) | ~2.5ms | 6 个 I2C 读 |
| MS5611 状态机 (I2C 操作) | ~400μs | 每次 Process 调用最多 1 个 I2C 事务 |
| OSTimeDlyHMSM → OS_Sched → PendSV | ~2μs | 上下文切回 Idle |

**最坏情况（MPU + HMC + MS5611 在同一 Tick 触发）：~8ms**，超出 5ms 目标周期。uC/OS-II 对此处理得当——任务只是比预期稍晚结束，`tick_counter` 仍递增 1。
