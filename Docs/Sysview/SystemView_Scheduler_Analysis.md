# SystemView 中的 "Scheduler" 是什么？

## 简短回答

**SystemView 中的 "Scheduler" 就是 PendSV + 调度决策时间。** 它代表了从 OS 决定切换任务到新任务实际开始运行之间的时间间隔。在你的代码中，它来自两个入口，最终都通过 PendSV 执行上下文切换。

---

## "Scheduler" 的两个来源

### 路径 A：ISR 触发（最频繁——每个 SysTick 1ms 一次）

当 `OSIntExit()` 发现需要切换任务时：

```
os_core.c:693  OSIntExit()
    │
    ├─ line 708:  OS_SchedNew()                    // 找到最高就绪任务
    ├─ line 709:  OSTCBHighRdy = OSTCBPrioTbl[...]
    ├─ line 710:  if (OSPrioHighRdy != OSPrioCur)  // 需要切换？
    │
    ├─ line 721:  OS_TRACE_ISR_EXIT_TO_SCHEDULER()
    │             └─→ SEGGER_SYSVIEW_RecordExitISRToScheduler()
    │                 ┌─────────────────────────────────────────┐
    │                 │  SystemView 在此处进入 "Scheduler"      │
    │                 │  上下文，ISR 上下文结束                  │
    │                 └─────────────────────────────────────────┘
    │
    └─ line 723:  OSIntCtxSw()
                   └─→ os_cpu_a.asm:276
                       LDR R0, =NVIC_INT_CTRL      // 0xE000ED04
                       LDR R1, =NVIC_PENDSVSET     // 0x10000000
                       STR R1, [R0]                // 设置 PendSV pending
                       BX  LR                      // 返回，ISR 结束
```

然后硬件尾链进入 PendSV：

```
os_cpu_a.asm:330  OS_CPU_PendSVHandler
    │
    ├─ 保存旧任务 R4-R11, R14 → OSTCBCur->OSTCBStkPtr
    │
    ├─ line 349:  BL  OSTaskSwHook
    │              └─→ os_trace_events.h:159
    │                  OS_TRACE_TASK_SWITCHED_IN(OSTCBHighRdy)
    │                  └─→ SYSVIEW_TaskSwitchedIn()
    │                      └─→ SEGGER_SYSVIEW_OnTaskStartExec()
    │                          ┌─────────────────────────────────────────┐
    │                          │  SystemView 在此处退出 "Scheduler"     │
    │                          │  上下文，新任务开始执行                 │
    │                          └─────────────────────────────────────────┘
    │
    ├─ 更新: OSPrioCur = OSPrioHighRdy
    ├─ 更新: OSTCBCur  = OSTCBHighRdy
    ├─ 恢复新任务 R4-R11, R14
    └─ BX  LR                          // 异常返回 → 新任务运行
```

**`RecordExitISRToScheduler` → ... → `OnTaskStartExec` 之间的时间段就是 SystemView 显示的 "Scheduler"。**

---

### 路径 B：任务级触发（每 5ms 一次，AppTaskSensor 延时）

当 AppTaskSensor 调用 `OSTimeDlyHMSM(0,0,0,5)` 时：

```
os_time.c:53  OSTimeDly(5)
    │
    ├─ 从就绪表移除 AppTaskSensor
    ├─ OSTCBCur->OSTCBDly = 5
    │
    └─ line 79: OS_Sched()
                 └─→ os_core.c:1702
                     │
                     ├─ line 1713: OS_SchedNew()
                     ├─ line 1714: OSTCBHighRdy = OSTCBPrioTbl[...]  // 指向 Idle任务
                     ├─ line 1715: if (OSPrioHighRdy != OSPrioCur)
                     │
                     └─ line 1727: OS_TASK_SW()
                                    └─→ Port/os_cpu.h:179
                                        #define OS_TASK_SW()  OSCtxSw()
                                        └─→ os_cpu_a.asm:275
                                            OSCtxSw:
                                            LDR R0, =NVIC_INT_CTRL
                                            LDR R1, =NVIC_PENDSVSET
                                            STR R1, [R0]       // 设置 PendSV pending
                                            BX  LR
```

PendSV 执行后 → `OSTaskSwHook` → `SYSVIEW_TaskSwitchedIn(Idle_TCB)` → `SEGGER_SYSVIEW_OnIdle()`

**任务级切换没有 `RecordExitISRToScheduler` 调用，但 SystemView 仍会在这段间隙显示 "Scheduler"——因为它检测到旧任务停止（进入延时）到新任务启动之间的调度活动。**

---

## 你的代码中哪些地方会触发 "Scheduler"

| 触发源 | 频率 | 代码位置 | 触发路径 |
|--------|------|----------|----------|
| **SysTick → 任务到期** | 每 1ms（但只有延时到期时才切换） | `os_core.c:721` | `OSIntExit()` → `OSIntCtxSw()` → PendSV |
| **AppTaskSensor 延时** | ~100-125Hz | `Src/main.c:123` | `OSTimeDly()` → `OS_Sched()` → `OSCtxSw()` → PendSV |
| **AppTaskDebug 延时** | 1Hz | `Src/main.c:132` | 同上 |
| **Idle 被抢占** | 每次 Sensor 就绪时 | `os_core.c:721` | `OSIntExit()` → PendSV |

---

## "Scheduler" = PendSV 吗？

**是的，本质上可以等同看待。**

| PendSV 做的事情 | SystemView 显示的 "Scheduler" |
|-----------------|------------------------------|
| 保存旧任务寄存器 (R4-R11, R14) | ← 这些都在 "Scheduler" 时间段内完成 |
| 更新 OSPrioCur = OSPrioHighRdy | |
| 更新 OSTCBCur = OSTCBHighRdy | |
| 调用 OSTaskSwHook（记录 OnTaskStartExec） | ← SystemView 在这里结束 "Scheduler" |
| 恢复新任务寄存器 (R4-R11, R14) | |
| BX LR → 新任务运行 | ← 新任务开始 |

唯一的细微差别是：
- `RecordExitISRToScheduler` 在 PendSV **触发之前**就已经调用了（在 `OSIntCtxSw()` 设置 pending 位之前）
- PendSV 处理程序的实际执行可能略有延迟（等待更高优先级中断完成）
- 这个延迟也在 "Scheduler" 时间内

**所以在 SystemView 中看到 "Scheduler" = 看到 PendSV 的开销。**

---

## 实际测量

PendSV 处理程序的执行时间约为：

- 无 FPU 上下文：~2μs（保存/恢复 R4-R11 + R14 约 9 个寄存器，2 次内存访问）
- 有 FPU 上下文（本项目启用了 FPU）：~5-10μs（额外保存/恢复 S16-S31）

在 SystemView 中，"Scheduler" 段的宽度代表了这个时间。如果你的 "Scheduler" 时间显著超过 10μs，说明可能有其他问题（如中断延迟、总线竞争等）。

---

## 代码位置速查

```
触发调度决策:
  os_core.c:693    OSIntExit()          // ISR 退出时的调度
  os_core.c:1702   OS_Sched()           // 任务级的调度
  os_time.c:79     OS_Sched() 调用      // OSTimeDly 内部

SystemView 追踪事件:
  os_core.c:721    OS_TRACE_ISR_EXIT_TO_SCHEDULER()  → 进入 Scheduler 上下文
  os_trace_events.h:175  #define → SEGGER_SYSVIEW_RecordExitISRToScheduler()

PendSV 触发:
  Port/os_cpu_a.asm:275   OSCtxSw       // 任务级触发 PendSV
  Port/os_cpu_a.asm:276   OSIntCtxSw    // ISR 级触发 PendSV（同一条指令）
  Port/os_cpu.h:179       #define OS_TASK_SW()  OSCtxSw()

PendSV 执行 (Scheduler 的实质):
  Port/os_cpu_a.asm:330   OS_CPU_PendSVHandler  // 上下文切换的实际执行
  Port/os_cpu_a.asm:349   BL OSTaskSwHook       // 记录 OnTaskStartExec → 退出 Scheduler
```

---

## 总结

```
你在 SystemView 中看到的:
┌──────────┬────────────┬──────────────┐
│  Idle    │ Scheduler  │ AppTaskSensor│
│ (运行中) │ (PendSV)   │ (开始运行)   │
└──────────┴────────────┴──────────────┘
           ↑
           这就是 OS_CPU_PendSVHandler 的执行时间
           在 os_cpu_a.asm:330-371
```

**"Scheduler" 就是 PendSV 的可见表现。** SystemView 用这个虚拟上下文来填补"旧任务停止"和"新任务开始"之间的空隙——而这个空隙正是 PendSV 处理程序在运行的时间。
