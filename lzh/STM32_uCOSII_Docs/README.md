# STM32 与 uC/OS-II 文档总览

本目录对原先分散在 `EventDriven`、`Startup`、`TimeDriven` 三个目录下的文档进行了统一重构，目标是让文档在主题划分、命名方式和阅读路径上保持一致。

## 目录结构

```text
STM32_uCOSII_Docs/
├── README.md
├── 01_startup_and_memory/
├── 02_event_driven/
└── 03_time_driven/
```

## 命名规则

1. 目录名采用 `编号_主题` 形式，体现阅读层次。
2. 文件名采用 `编号_主题说明.md` 形式，统一使用小写下划线风格。
3. 内容组织遵循“基础原理 -> 机制分析 -> 工程实现”的顺序，避免主题交叉。

## 推荐阅读顺序

1. 启动与内存基础
   - [01_compilation_process.md](./01_startup_and_memory/01_compilation_process.md)
   - [02_stm32f401ret6_memory_architecture.md](./01_startup_and_memory/02_stm32f401ret6_memory_architecture.md)
   - [03_load_view_vs_execution_view.md](./01_startup_and_memory/03_load_view_vs_execution_view.md)
   - [04_startup_flow_and_vector_table.md](./01_startup_and_memory/04_startup_flow_and_vector_table.md)
   - [05_bootloader_minimal_guide.md](./01_startup_and_memory/05_bootloader_minimal_guide.md)
2. 事件驱动机制
   - [01_event_driven_mechanism.md](./02_event_driven/01_event_driven_mechanism.md)
3. 时间驱动机制
   - [01_time_driven_mechanism.md](./03_time_driven/01_time_driven_mechanism.md)

## 文档分组说明

### 01_startup_and_memory

这一组关注程序“如何被构建、放入存储器并启动运行”，适合作为 STM32 裸机与 RTOS 学习的前置基础。

| 文件 | 主题 |
| --- | --- |
| `01_compilation_process.md` | 从源文件到可执行镜像的构建流程 |
| `02_stm32f401ret6_memory_architecture.md` | STM32F401RET6 的存储器布局与总线结构 |
| `03_load_view_vs_execution_view.md` | 加载视图、执行视图以及 RW/ZI 的启动搬运逻辑 |
| `04_startup_flow_and_vector_table.md` | 从复位到 `main()` 的启动链路与向量表机制 |
| `05_bootloader_minimal_guide.md` | Bootloader 最小实现、跳转逻辑与 App 改造 |

### 02_event_driven

这一组关注“中断如何触发调度”，主线是 NVIC、优先级、PendSV 和上下文切换。

| 文件 | 主题 |
| --- | --- |
| `01_event_driven_mechanism.md` | STM32 与 uC/OS-II 的事件驱动调度机制 |

### 03_time_driven

这一组关注“时钟节拍如何驱动系统前进”，主线是 SysTick、OSTimeTick、延时与软件定时器。

| 文件 | 主题 |
| --- | --- |
| `01_time_driven_mechanism.md` | uC/OS-II 时间驱动机制与 Tick 服务 |

## 关联阅读

如果需要继续沿着 RTOS 调度链路深入，可以结合 `lzh/usOSii` 目录中的 `PendSV.md` 等文档继续阅读。
