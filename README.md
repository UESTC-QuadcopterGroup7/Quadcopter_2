# 四旋翼飞控系统 — uC/OS-II + SystemView 实时分析

> **硬件平台**: STM32F401RETx (Cortex-M4, 84MHz)  
> **RTOS**: Micrium uC/OS-II  
> **调试工具链**: Keil MDK + SEGGER J-Link + SystemView  
> **版本**: SystemView Target Source 3.32

---

## 目录

1. [项目目录结构](#1-项目目录结构)
2. [SystemView 移植实现分析](#2-systemview-移植实现分析)
3. [如何使用 SystemView](#3-如何使用-systemview)
4. [自定义事件与扩展](#4-自定义事件与扩展)
5. [常见问题排查](#5-常见问题排查)

---

## 1. 项目目录结构

```
Quadcopter_2/
├── SEGGER/                          # ★ SystemView & RTT 全部源码
│   ├── Config/                      # 配置文件
│   │   ├── Global.h                 #   基础类型定义 (U8/U16/U32/I8/I16/I32)
│   │   ├── SEGGER_RTT_Conf.h        #   RTT 用户配置 (本项目中为空，使用默认值)
│   │   └── SEGGER_SYSVIEW_Conf.h    #   SystemView 用户配置 (可在此覆盖默认宏)
│   │
│   ├── RTT/                         # SEGGER RTT (Real-Time Transfer) 实现
│   │   ├── SEGGER_RTT.h             #   RTT API 头文件 & 环形缓冲区结构体定义
│   │   ├── SEGGER_RTT.c             #   RTT 核心实现 (缓冲区读写、初始化)
│   │   ├── SEGGER_RTT_ConfDefaults.h #  RTT 默认配置 (缓冲区大小、通道数、锁定机制)
│   │   └── SEGGER_RTT_printf.c      #   RTT printf 格式化输出
│   │
│   ├── SystemView/                  # SystemView 核心实现
│   │   ├── SEGGER.h                 #   SEGGER 公共工具 (内存操作、字符串、printf)
│   │   ├── SEGGER_SYSVIEW.h         #   SystemView 公开 API 头文件
│   │   ├── SEGGER_SYSVIEW.c         #   ★ 核心实现 (~4295行): 事件编码/发送/初始化
│   │   ├── SEGGER_SYSVIEW_Int.h     #   内部命令定义 (START/STOP/GET_TASKLIST等)
│   │   └── SEGGER_SYSVIEW_ConfDefaults.h  # 默认配置 (自动检测Cortex-M核心)
│   │
│   └── uCOS-II/                     # uC/OS-II 专用集成层
│       ├── os_cfg_trace.h           #   跟踪配置: 最大任务数32, 最大资源数128
│       ├── os_trace_events.h        #   ★ uC/OS-II Trace 宏 → SystemView API 映射
│       ├── SEGGER_SYSVIEW_uCOSII.c  #   ★ uC/OS-II 任务/资源跟踪实现
│       └── SEGGER_SYSVIEW_Config_Quadcopter.c  # ★ 四旋翼项目 SystemView 配置入口
│
├── Source/                          # uC/OS-II 内核源码
│   ├── ucos_ii.h                    #   uC/OS-II 主头文件
│   ├── ucos_ii.c                    #   内核入口
│   ├── os_core.c                    #   核心调度器
│   ├── os_task.c                    #   任务管理
│   ├── os_sem.c / os_mutex.c / ... #   IPC 机制
│   ├── os_trace.h                   #   uC/OS-II Trace 框架 (宏默认空实现)
│   └── os_tmr.c / os_time.c / ...  #   定时器 & 时间管理
│
├── Port/                            # uC/OS-II Cortex-M4 移植层
│   ├── os_cpu.h                     #   CPU 相关定义
│   ├── os_cpu_a.asm                 #   汇编: PendSV/SysTick 上下文切换
│   └── os_cpu_c.c                   #   C: 任务栈初始化
│
├── Config/                          # 应用 & OS 配置
│   ├── app_cfg.h                    #   应用配置: 任务优先级/栈大小/跟踪级别
│   └── os_cfg.h                     #   uC/OS-II 内核配置 (开关各模块)
│
├── Src/                             # 用户应用代码
│   ├── main.c                       #   main(): 初始化 → 创建启动任务 → OSStart()
│   └── stm32f4xx_it.c               #   中断服务函数
│
├── MyLib/                           # 外设驱动库
│   ├── BLDC.c/h                     #   无刷电机 PWM 驱动 (TIM3)
│   ├── GY86.c/h                     #   MPU6050 陀螺仪/加速度计 (I2C)
│   ├── OLED.c/h                     #   OLED 显示屏
│   ├── Receive_IC.c/h               #   输入捕获 (PWM 遥控器信号读取)
│   ├── BMP180.c/h                   #   气压计
│   ├── MyI2C.c/h                    #   I2C 软件模拟
│   ├── Delay.c/h                    #   延时函数
│   ├── ReadPeripherals.c/h          #   外设数据汇总读取
│   └── GPIO_Set.h / PWM_Set.h / ...  # GPIO/PWM/USART 配置
│
├── Drivers/                         # STM32 HAL 库
│   ├── CMSIS/                       #   Cortex-M 内核接口
│   └── STM32F4xx_HAL_Driver/        #   STM32F4 HAL 驱动
│
├── ucCPU/                           # Micrium uC/CPU 组件
│   └── cpu_core.c / cpu_core.h / ...
│
├── ucLib/                           # Micrium uC/LIB 组件
│   └── lib_mem.c / lib_str.c / ...
│
├── Hardware/                        # 硬件文档
│   ├── BEQ.md                       #   蜂鸣器说明
│   ├── Battery.md                   #   电池说明
│   ├── ESC.md                       #   电调说明
│   └── Wiring.md                    #   接线说明
│
├── Inc/                             # HAL 配置头文件
├── RTE/                             # Keil RTE 运行时环境
├── DebugConfig/                     # Keil 调试配置
├── Listings/                        # 编译生成的 .lst 文件
├── Objects/                         # 编译生成的 .o 文件
├── LED.uvprojx                      # Keil MDK 工程文件
└── README.md                        # 本文档
```

### SystemView 文件依赖关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                      PC 端 SystemView 应用程序                    │
│               (可视化任务切换、中断、RTOS 事件时间线)               │
└──────────────────────────┬──────────────────────────────────────┘
                           │ J-Link SWD 接口
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                        SEGGER RTT                                │
│  SEGGER_RTT.c / SEGGER_RTT.h / SEGGER_RTT_ConfDefaults.h        │
│  - 环形缓冲区 (上/下行通道)                                       │
│  - 内存映射传输 (无需额外 UART)                                   │
│  - 中断安全锁定机制                                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SEGGER SystemView 核心                       │
│  SEGGER_SYSVIEW.c / SEGGER_SYSVIEW.h                             │
│  - 事件包编码 (U32变长编码)                                       │
│  - 时间戳管理 (Delta 增量编码)                                    │
│  - 同步 & 系统描述                                                │
│  - 主机命令处理 (START/STOP/GET_TASKLIST…)                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                 uC/OS-II Trace 集成层                             │
│  os_trace_events.h (宏映射层)                                     │
│  SEGGER_SYSVIEW_uCOSII.c (任务/资源跟踪)                          │
│  SEGGER_SYSVIEW_Config_Quadcopter.c (系统配置)                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              uC/OS-II 内核 (嵌入 Trace Hook)                      │
│  os_core.c / os_task.c / os_time.c / ...                         │
│  #include "os_trace.h"  → 内核关键路径自动调用 Trace 宏            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. SystemView 移植实现分析

### 2.1 整体架构

本项目的 SystemView 移植基于 SEGGER 官方的 SystemView Target Source，实现了对 **uC/OS-II** 实时操作系统的完整事件追踪。整体架构分为四层：

| 层次 | 组件 | 职责 |
|------|------|------|
| **传输层** | SEGGER RTT | 通过 J-Link 调试器实现 Target → Host 的高速数据传输 |
| **协议层** | SEGGER SystemView Core | 事件包编码、时间戳管理、主机命令处理 |
| **OS 适配层** | uC/OS-II Trace 宏 + SYSVIEW_uCOSII | 将 uC/OS-II 内核事件映射为 SystemView 事件 |
| **应用配置层** | SEGGER_SYSVIEW_Config_Quadcopter | 板级参数配置 (时钟频率、RAM基址、中断映射) |

### 2.2 RTT 传输层

**RTT (Real-Time Transfer)** 是 SEGGER 的专有传输技术，通过 J-Link 的 SWD 接口直接读写 MCU 内存中的环形缓冲区，无需占用额外的串口硬件：

- **上通道 (Up-Buffer)**: Target → Host，用于发送 SystemView 事件包，默认 1024 字节
- **下通道 (Down-Buffer)**: Host → Target，用于接收 PC 端命令 (START/STOP 等)，8 字节
- **通道命名**: SystemView 的 RTT 通道被标记为 `"SysView"`，PC 端软件据此识别
- **中断保护**: 对于 Cortex-M4，通过操作 `BASEPRI` 寄存器实现可嵌套的临界区保护

```c
// RTT 关键配置 (来自 SEGGER_RTT_ConfDefaults.h)
#define SEGGER_RTT_MAX_NUM_UP_BUFFERS    (3)    // 最多3个上通道
#define SEGGER_RTT_MAX_NUM_DOWN_BUFFERS  (3)    // 最多3个下通道
#define BUFFER_SIZE_UP                   (1024) // 通道0 缓冲区大小
#define SEGGER_RTT_MODE_DEFAULT  SEGGER_RTT_MODE_NO_BLOCK_SKIP  // 默认非阻塞模式
```

### 2.3 内核自动检测

`SEGGER_SYSVIEW_ConfDefaults.h` 通过编译器预定义宏自动识别 Cortex-M 内核：

- **本项目 (STM32F401RE Cortex-M4)**: 被识别为 `SEGGER_SYSVIEW_CORE_CM3`
- **时间戳获取**: 直接读取 Cortex-M DWT 周期计数器 `*(U32*)(0xE0001004)` (CYCCNT)
- **中断 ID 获取**: 读取 ICSR 寄存器 `*(U32*)(0xE000ED04) & 0x1FF`

```c
// 自动生成的宏定义 (无需手动编写)
#define SEGGER_SYSVIEW_GET_TIMESTAMP()   (*(U32 *)(0xE0001004))  // DWT CYCCNT
#define SEGGER_SYSVIEW_GET_INTERRUPT_ID() ((*(U32*)(0xE000ED04)) & 0x1FF)  // ICSR
```

### 2.4 uC/OS-II Trace 钩子机制

uC/OS-II 内核在 `os_trace.h` 中预埋了大量 Trace 钩子宏，默认为空实现。SystemView 通过 `os_trace_events.h` 将其替换为实际的 SystemView API 调用。

**核心钩子映射** (定义在 `SEGGER/uCOS-II/os_trace_events.h`):

| uC/OS-II Trace 宏 | SystemView API | 触发时机 |
|---|---|---|
| `OS_TRACE_INIT()` | `SEGGER_SYSVIEW_Conf()` | 系统初始化 |
| `OS_TRACE_TASK_CREATE(p_tcb)` | `SEGGER_SYSVIEW_OnTaskCreate()` + `SYSVIEW_AddTask()` | 任务创建 |
| `OS_TRACE_TASK_READY(p_tcb)` | `SYSVIEW_TaskReady()` → `SEGGER_SYSVIEW_OnTaskStartReady()` | 任务就绪 |
| `OS_TRACE_TASK_SWITCHED_IN(p_tcb)` | `SYSVIEW_TaskSwitchedIn()` → `SEGGER_SYSVIEW_OnTaskStartExec()` | 任务切入 |
| `OS_TRACE_TASK_SUSPENDED(p_tcb)` | `SYSVIEW_TaskSuspend()` → `SEGGER_SYSVIEW_OnTaskStopReady()` | 任务挂起 |
| `OS_TRACE_ISR_ENTER()` | `SEGGER_SYSVIEW_RecordEnterISR()` | 进入 ISR |
| `OS_TRACE_ISR_EXIT()` | `SEGGER_SYSVIEW_RecordExitISR()` | 退出 ISR |
| `OS_TRACE_ISR_EXIT_TO_SCHEDULER()` | `SEGGER_SYSVIEW_RecordExitISRToScheduler()` | ISR 退出时触发调度 |
| `OS_TRACE_TICK_INCREMENT(tick)` | `SEGGER_SYSVIEW_RecordU32()` | 系统时钟节拍 |
| `OS_TRACE_SEM_CREATE(...)` | `SYSVIEW_RecordU32Register()` | 信号量创建 |
| `OS_TRACE_MUTEX_CREATE(...)` | `SYSVIEW_RecordU32Register()` | 互斥量创建 |
| `OS_TRACE_Q_CREATE(...)` | `SYSVIEW_RecordU32Register()` | 消息队列创建 |

**事件 ID 分配**: uC/OS-II 事件从 ID=32 开始 (0-31 为 SystemView 保留事件)

```c
#define OS_TRACE_ID_OFFSET    (32u)
#define OS_TRACE_ID_SEM_CREATE (14u + OS_TRACE_ID_OFFSET)  // = 46
#define OS_TRACE_ID_SEM_POST   (16u + OS_TRACE_ID_OFFSET)  // = 48
// ... 共35个 uC/OS-II 专项事件
```

**空闲任务特殊处理**: SystemView 将 uC/OS-II 空闲任务单独记录为 `SYSVIEW_EVTID_IDLE` 事件（而非普通任务执行），在 PC 端显示为独立的空闲时间区域。

### 2.5 任务与资源跟踪 (`SEGGER_SYSVIEW_uCOSII.c`)

该文件维护两个内部数组来管理 RTOS 对象信息：

```c
// 任务列表 (最大容量由 OS_CFG_TRACE_MAX_TASK 定义, 默认 32)
static SYSVIEW_UCOSII_TASK_STATUS _aTasks[OS_CFG_TRACE_MAX_TASK];

// 资源列表 (最大容量由 OS_CFG_TRACE_MAX_RESOURCES 定义, 默认 128)
static SYSVIEW_UCOSII_RESOURCE _aResources[OS_CFG_TRACE_MAX_RESOURCES];
```

**关键 API**:

| 函数 | 功能 |
|------|------|
| `SYSVIEW_AddTask()` | 注册新任务，记录 ID/名称/优先级/栈底/栈大小 |
| `SYSVIEW_UpdateTask()` | 更新已有任务信息 (如调用了 `OSTaskNameSet()`) |
| `SYSVIEW_TaskReady()` | 任务进入就绪态 (过滤空闲任务) |
| `SYSVIEW_TaskSwitchedIn()` | 任务开始执行 / 空闲任务记录 Idle |
| `SYSVIEW_TaskSuspend()` | 任务被挂起 |
| `SYSVIEW_RecordU32Register()` | 注册内核对象 (信号量/互斥量/队列等) 并记录名称 |

**OS_API 回调结构体**: SystemView 通过此结构体获取 OS 层能力

```c
const SEGGER_SYSVIEW_OS_API SYSVIEW_X_OS_TraceAPI = {
    _cbGetTime,       // pfGetTime:     返回 uC/OS-II 系统时间 (us)
    _cbSendTaskList,  // pfSendTaskList: 向主机发送完整任务列表
};
```

### 2.6 项目配置文件 (`SEGGER_SYSVIEW_Config_Quadcopter.c`)

这是 SystemView 的顶层配置入口，SEGGER 要求每个项目必须实现 `SEGGER_SYSVIEW_Conf()` 函数：

```c
void SEGGER_SYSVIEW_Conf(void) {
    // 1. 初始化 SystemView 核心: 系统时钟=CPU时钟=84MHz
    SEGGER_SYSVIEW_Init(SystemCoreClock,           // SysFreq: 时间戳频率
                        SystemCoreClock,           // CPUFreq: CPU 频率
                        &SYSVIEW_X_OS_TraceAPI,    // uC/OS-II OS API 回调
                        _cbSendSystemDesc);        // 系统描述回调

    // 2. 设置 RAM 基地址 (用于 ID 压缩，节省带宽)
    SEGGER_SYSVIEW_SetRAMBase(0x20000000u);
}

// 系统描述回调 — 在 PC 端 SystemView 中显示
static void _cbSendSystemDesc(void) {
    SEGGER_SYSVIEW_SendSysDesc("N=Quadcopter_uCOSII,"
                               "D=STM32F401RETx,"
                               "O=uC/OS-II");
    SEGGER_SYSVIEW_SendSysDesc("I#15=SysTick");   // 中断 #15 → SysTick
    SEGGER_SYSVIEW_SendSysDesc("I#44=TIM2");       // 中断 #44 → TIM2
    SEGGER_SYSVIEW_SendSysDesc("I#46=TIM4");       // 中断 #46 → TIM4
}
```

### 2.7 事件包编码机制

SystemView 使用自定义的变长编码 (Variable-Length Encoding) 来压缩数据：

```
U32 编码规则 (每字节 7bit 数据 + 1bit 续标志):
  - 值 ≤ 0x7F:        1 byte  (0XXXXXXX)
  - 值 ≤ 0x3FFF:      2 bytes (1XXXXXXX 0XXXXXXX)
  - 值 ≤ 0x1FFFFF:    3 bytes
  - 值 ≤ 0xFFFFFFF:   4 bytes
  - 值 ≤ 0xFFFFFFFF:  5 bytes (1XXXXXXX 1XXXXXXX 1XXXXXXX 1XXXXXXX 0000XXXX)

时间戳 Delta 编码:
  - 相邻事件的 Delta = CurrentTimestamp - LastTxTimestamp
  - 高频事件通常只需 1-2 bytes 编码 Delta
```

**数据包格式**:

```
标准系统事件 (ID 0-23):
  [1B EventID] [N bytes Payload] [1-5B TimestampDelta]

扩展系统事件 (ID 24-30):
  [1B EventID] [1-5B Length] [N bytes Payload] [1-5B TimestampDelta]

用户自定义事件 (ID ≥ 32):
  [1-5B EventID] [1-5B Length] [N bytes Payload] [1-5B TimestampDelta]
```

**ID 压缩**: 将任务/资源地址减去 `RAMBaseAddress` (0x20000000)，使 ID 值变小，减少传输字节数。

---

## 3. 如何使用 SystemView

### 3.1 前置条件

- **硬件**: SEGGER J-Link 调试器 (EDU/Mini/Plus/Ultra+ 均可)
- **软件**: [SEGGER SystemView PC 端](https://www.segger.com/downloads/systemview/) (免费)
- **IDE**: Keil MDK (项目使用 LED.uvprojx)
- **目标板**: STM32F401RETx 通过 SWD 接口连接 J-Link

### 3.2 启用 SystemView (编译配置)

#### Step 1: 在 `os_cfg.h` 中启用 Trace

```c
#define OS_TRACE_EN              1u   // 启用 uC/OS-II Trace 框架
#define OS_TRACE_API_ENTER_EN    0u   // (可选) 启用 API 进入事件
#define OS_TRACE_API_EXIT_EN     0u   // (可选) 启用 API 退出事件
```

#### Step 2: 将以下文件加入 Keil 工程编译列表

```
SEGGER/RTT/SEGGER_RTT.c
SEGGER/RTT/SEGGER_RTT_printf.c
SEGGER/SystemView/SEGGER_SYSVIEW.c
SEGGER/uCOS-II/SEGGER_SYSVIEW_uCOSII.c
SEGGER/uCOS-II/SEGGER_SYSVIEW_Config_Quadcopter.c
```

#### Step 3: 确认头文件包含路径

在 Keil 工程的 `Options → C/C++ → Include Paths` 中添加：

```
./SEGGER/Config
./SEGGER/RTT
./SEGGER/SystemView
./SEGGER/uCOS-II
```

#### Step 4: 编译烧录

编译工程并通过 J-Link 烧录到目标板。

### 3.3 使用 SystemView PC 端记录数据

#### 连接步骤

1. **启动 SystemView PC 应用程序**
   ```
   Windows: 开始菜单 → SEGGER → SystemView
   ```

2. **配置目标设备** (`Target → Recorder Configuration`)
   - **Recorder**: `SEGGER J-Link`
   - **Target Device**: `STM32F401RE`
   - **Target Interface**: `SWD`
   - **Speed**: `Auto` 或 `4000 kHz`

3. **启动记录** (按 `F5` 或点击 ▶ 按钮)
   - SystemView 通过 J-Link 自动连接目标板
   - 发送 `START` 命令到目标
   - 开始接收事件数据

4. **停止记录** (按 `F5` 或点击 ⏹ 按钮)
   - SystemView 发送 `STOP` 命令
   - 数据自动保存为 `.SVdat` 文件

### 3.4 查看分析数据

SystemView 主界面分为几个区域：

| 区域 | 内容 | 说明 |
|------|------|------|
| **Timeline (时间线)** | 各任务/中断的执行时间段 | 水平条表示运行中，彩色区分不同任务 |
| **Events (事件列表)** | 原始事件流 | 可筛选特定类型事件 |
| **CPU Load (CPU负载)** | 各任务占用百分比 | 识别性能瓶颈 |
| **Context (上下文)** | 任务详情 (优先级/栈使用) | 点击任务名查看 |

**关键分析指标**:
- **任务执行时间**: 识别哪个任务占用 CPU 最多
- **任务切换频率**: 评估调度器开销
- **中断延迟**: ISR Enter 到 ISR Exit 的时间
- **空闲时间**: `Idle` 区域大小反映 CPU 利用率

### 3.5 运行时命令

SystemView PC 端可主动向目标发送命令：

| 命令 | 功能 |
|------|------|
| `START` | 开始记录 (目标 `EnableState` 0→1) |
| `STOP` | 停止记录 (目标 `EnableState` 1→0) |
| `GET_TASKLIST` | 请求目标重新发送任务列表 |
| `GET_SYSDESC` | 请求目标重新发送系统描述 |
| `HEARTBEAT (127)` | 心跳检测，验证 RTT 通道通畅 |

### 3.6 关键配置参数速查

| 参数 | 默认值 | 位置 | 说明 |
|------|--------|------|------|
| `SEGGER_SYSVIEW_RTT_BUFFER_SIZE` | 1024 | ConfDefaults.h | RTT 上行缓冲区大小 (字节) |
| `SEGGER_SYSVIEW_MAX_STRING_LEN` | 128 | ConfDefaults.h | 事件中字符串最大长度 |
| `OS_CFG_TRACE_MAX_TASK` | 32 | os_cfg_trace.h | 可记录的最大任务数 |
| `OS_CFG_TRACE_MAX_RESOURCES` | 128 | os_cfg_trace.h | 可记录的最大内核对象数 |
| `SEGGER_SYSVIEW_ID_BASE` | 0 | 由 SetRAMBase 覆盖 | ID 压缩基址 (=0x20000000) |
| `SEGGER_SYSVIEW_RTT_CHANNEL` | 0 | ConfDefaults.h | 使用的 RTT 通道号 |

---

## 4. 自定义事件与扩展

### 4.1 添加用户自定义事件

在应用代码中使用 SystemView 录制函数：

```c
#include "SEGGER_SYSVIEW.h"

#define MY_CUSTOM_EVENT_ID    (0x400)  // 用户事件 ID 范围: 1024-2047

// 方式1: 录制单个参数
SEGGER_SYSVIEW_RecordU32(MY_CUSTOM_EVENT_ID, sensorValue);

// 方式2: 录制多个参数
SEGGER_SYSVIEW_RecordU32x2(MY_CUSTOM_EVENT_ID, throttleValue, yawValue);

// 方式3: 录制字符串
SEGGER_SYSVIEW_RecordString(MY_CUSTOM_EVENT_ID, "Event description");

// 方式4: Mark 标记 (开始/结束)
SEGGER_SYSVIEW_MarkStart(0);   // 开始标记 #0
// ... 被测代码 ...
SEGGER_SYSVIEW_MarkStop(0);    // 结束标记 #0

// 方式5: 格式化字符串
SEGGER_SYSVIEW_PrintfHost("Motor PWM: %u us", pulseWidth);
```

### 4.2 添加中断名称映射

在 `SEGGER_SYSVIEW_Config_Quadcopter.c` 的 `_cbSendSystemDesc()` 中注册：

```c
SEGGER_SYSVIEW_SendSysDesc("I#XX=InterruptName");  // XX = 中断向量号
```

### 4.3 使用 Post-Mortem 模式

Post-Mortem 模式允许在未连接 SystemView 的情况下持续记录，事后通过 J-Link 读取数据：

```c
// 在 SEGGER_SYSVIEW_Conf.h 中添加:
#define SEGGER_SYSVIEW_POST_MORTEM_MODE    1
#define SEGGER_SYSVIEW_START_ON_INIT       1   // 启动即开始记录
```

---

## 5. 常见问题排查

### Q1: SystemView 连接后没有数据显示
- 确认 `OS_TRACE_EN` 已设为 `1`
- 确认 `SEGGER_SYSVIEW_Config_Quadcopter.c` 和 `SEGGER_SYSVIEW_uCOSII.c` 已编译进工程
- 确认 J-Link 驱动版本和 SystemView 版本兼容
- 在 SystemView 中检查 RTT 控制块是否被正确识别 (`SEGGER RTT` 魔数)

### Q2: 数据不完整 / 有丢包
- 增大 `SEGGER_SYSVIEW_RTT_BUFFER_SIZE` (如改为 2048 或 4096)
- 减少事件记录频率 (通过 `SEGGER_SYSVIEW_DisableEvents()` 关闭不必要的事件)
- 确认 RTT 上通道模式为 `SEGGER_RTT_MODE_NO_BLOCK_SKIP` (丢新不阻塞)
- 检查是否有高优先级中断长时间占用 CPU

### Q3: SystemView 中看不到任务名称
- 确认所有任务都在创建时设置了名称 (`OSTaskNameSet()`)
- 检查 `OS_CFG_TRACE_MAX_TASK` 是否足够大
- 检查 `_cbSendTaskList()` 是否在 Start 时被正确调用

### Q4: 编译错误 `#error "SEGGER_RTT_MAX_NUM_UP_BUFFERS ... has to be > 1!"`
- SystemView 使用 RTT Channel 0 时至少需要 2 个上通道
- 确认 `SEGGER_RTT_MAX_NUM_UP_BUFFERS >= 2`

### Q5: 时间戳看起来不对
- 确认 `SEGGER_SYSVIEW_Init()` 传入的 `SysFreq` 等于实际时间戳时钟频率
- 本项目使用 `SystemCoreClock` (84MHz)，即 DWT 周期计数器的递增速率
- 如使用 SysTick 作为时间源，需使能 DWT 并设置相应频率

### Q6: 当前工程状态 (未启用 SystemView)

Master 分支中 `OS_TRACE_EN` 默认为 **未启用** 状态。`SEGGER_SYSVIEW_Config_Quadcopter.c` 文件头注释明确标注：

> *"This file is intentionally added to Keil as a non-compiled file for now. To enable SystemView later, compile this file together with SEGGER_SYSVIEW_uCOSII.c and enable the uC/OS-II trace hooks."*

如需启用，请参照 [3.2 节](#32-启用-systemview-编译配置) 的步骤操作。

---

## 参考资源

- [SEGGER SystemView 官方文档](https://www.segger.com/products/development-tools/systemview/)
- [SEGGER RTT 技术说明](https://www.segger.com/products/debug-probes/j-link/technology/about-real-time-transfer/)
- [SystemView GitHub](https://github.com/SEGGERMicro/SystemView)
- [uC/OS-II 官方文档](https://doc.micrium.com)
