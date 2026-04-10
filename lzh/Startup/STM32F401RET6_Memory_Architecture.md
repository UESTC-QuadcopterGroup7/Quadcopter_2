# STM32F401RET6 内存架构详解

本文档详细解析 **STM32F401RET6** 微控制器的内存架构。该芯片基于 ARM Cortex-M4F 内核，具有 512KB Flash 和 96KB SRAM。理解其内存架构对于优化程序性能、合理规划存储空间以及使用 DMA 至关重要。

## 1. 系统架构概览 (System Architecture)

STM32F401RET6 采用 **32位多层 AHB 总线矩阵 (Multi-AHB Bus Matrix)**，实现了主控设备 (Master) 与从设备 (Slave) 之间的并发访问。

### 1.1 主控设备 (Masters)
系统主要由以下主控设备发起数据传输：
*   **Cortex-M4F 内核**：
    *   **I-Bus (Instruction Bus)**: 用于获取指令（从 Flash 或 SRAM）。
    *   **D-Bus (Data Bus)**: 用于加载和存储数据（调试访问也通过此总线）。
    *   **S-Bus (System Bus)**: 用于访问外设、SRAM 或系统控制空间。
*   **DMA1**: 通用 DMA 控制器 1（主要服务于 APB1 外设）。
*   **DMA2**: 通用 DMA 控制器 2（主要服务于 APB2 外设和内存到内存传输）。
*   **USB OTG FS**: USB 控制器。

### 1.2 从设备 (Slaves)
被访问的资源包括：
*   **Internal Flash (ICode/DCode)**: 内部 Flash 存储器（通过 ACCEL 加速器接口）。
*   **SRAM1**: 96KB 内部静态随机存取存储器。
*   **AHB1/AHB2 外设**: 如 GPIO, CRC 等。
*   **APB1/APB2 外设**: 如 UART, SPI, I2C, TIM 等（通过桥接器）。

> **关键点**: 总线矩阵允许并行访问。例如，当 CPU 从 Flash 读取指令时，DMA 可以同时将数据从串口搬运到 SRAM，二者互不干扰，从而提高系统效率。

---

## 2. 内存映射 (Memory Map)

Cortex-M4 具有 4GB 的统一线性地址空间。STM32F401RET6 的具体映射如下：

| 区域 (Block) | 地址范围 (Address Range) | 大小 | 描述 |
| :--- | :--- | :--- | :--- |
| **Code** | `0x0000 0000` - `0x1FFF FFFF` | 512MB | 包含 Flash 映射、System Memory 等 |
| **SRAM** | `0x2000 0000` - `0x3FFF FFFF` | 512MB | 包含内部 SRAM |
| **Peripherals** | `0x4000 0000` - `0x5FFF FFFF` | 512MB | 片上外设寄存器 (Bit-band 别名区支持) |

### 2.1 详细分区表

| 存储器类型 | 起始地址 | 大小 | 实际物理位置/用途 |
| :--- | :--- | :--- | :--- |
| **Flash Memory** | `0x0800 0000` | **512 KB** | 存放用户代码和常量 (Main Memory) |
| **System Memory** | `0x1FFF 0000` | 30 KB | 出厂固化的 Bootloader (用于串口/USB下载) |
| **OTP Area** | `0x1FFF 7800` | 512 Bytes | 一次性可编程区域 (One-Time Programmable) |
| **Option Bytes** | `0x1FFF C000` | 16 Bytes | 配置读写保护、看门狗、BOR 复位电平等 |
| **SRAM1** | `0x2000 0000` | **96 KB** | 存放变量、堆、栈 (无 CCM RAM) |

---

## 3. Flash 存储器详解 (Embedded Flash)

STM32F401RET6 的 512KB Flash 并不是连续均匀的，而是被划分为 **8 个扇区 (Sectors)**。

### 3.1 扇区划分 (Sector Mapping)
擦除操作必须按扇区进行，这对于参数存储（EEPROM 模拟）非常重要。

| 扇区索引 | 扇区大小 | 地址范围 | 建议用途 |
| :--- | :--- | :--- | :--- |
| **Sector 0** | 16 KB | `0x0800 0000` - `0x0800 3FFF` | 中断向量表, 启动代码 |
| **Sector 1** | 16 KB | `0x0800 4000` - `0x0800 7FFF` | **用户配置参数存储** (推荐) |
| **Sector 2** | 16 KB | `0x0800 8000` - `0x0800 BFFF` | 用户配置参数存储 / 日志 |
| **Sector 3** | 16 KB | `0x0800 C000` - `0x0800 FFFF` | 用户配置参数存储 / 日志 |
| **Sector 4** | 64 KB | `0x0801 0000` - `0x0801 FFFF` | 主应用程序代码 |
| **Sector 5** | 128 KB | `0x0802 0000` - `0x0803 FFFF` | 主应用程序代码 |
| **Sector 6** | 128 KB | `0x0804 0000` - `0x0805 FFFF` | 主应用程序代码 / 资源数据 |
| **Sector 7** | 128 KB | `0x0806 0000` - `0x0807 FFFF` | 主应用程序代码 / 文件系统 |

> **设计建议**:
> *   **参数存储**: 优先使用 Sector 1, 2, 3。因为它们仅 16KB，擦除速度快（典型值 200ms），不会造成系统长时间阻塞。相比之下，128KB 扇区擦除可能需要 1-2 秒。
> *   **代码保护**: 可以在 Option Bytes 中对特定扇区设置写保护。

### 3.2 Flash 逻辑段划分 (Linker Sections)
编译后的程序在 Flash 中主要分为以下几个逻辑段：

| 段名 (Section) | 内容 (Content) | 属性 (Attribute) | 说明 |
| :--- | :--- | :--- | :--- |
| **.text** | **程序代码** | Read-Only (RO) | 存放编译后的机器指令。 |
| **.rodata** | **只读常量** | Read-Only (RO) | 存放 `const` 修饰的变量、字符串字面量等。 |
| **.data** (LMA) | **已初始化变量的初值** | Read-Only (RO) | 存放全局/静态变量的初始值。系统启动时，启动代码会将这些数据从 Flash 复制到 SRAM 的 `.data` (VMA) 区。 |
| **Vector Table** | **中断向量表** | Read-Only (RO) | 存放栈顶地址和所有中断服务函数的入口地址（通常位于 Flash 起始处）。 |

> **LMA vs VMA**:
> *   **LMA (Load Memory Address)**: 加载地址，即数据在 Flash 中的存储位置。
> *   **VMA (Virtual Memory Address)**: 运行地址，即 CPU 运行时访问该数据的地址（通常在 SRAM）。
> *   对于 `.text` 和 `.rodata`，LMA 等于 VMA（因为它们直接在 Flash 运行）。
> *   对于 `.data`，LMA 在 Flash，VMA 在 SRAM。

### 3.3 性能加速 (ART Accelerator)
Flash 的读取速度（最高约 24MHz）远低于 CPU 主频（84MHz）。为了不拖累 CPU，STM32F4 引入了 ART 加速器：
*   **指令预取 (Prefetch Queue)**: 预取后续指令。
*   **指令缓存 (Instruction Cache, I-Cache)**: 64 行，128 位宽。
*   **数据缓存 (Data Cache, D-Cache)**: 8 行，128 位宽。
*   **等待周期 (Wait States)**: 在 84MHz (3.3V) 下，需要配置 **2WS (Wait States)**。开启 ART 后，性能可接近 0WS 运行。

---

## 4. SRAM 存储器详解

STM32F401RET6 拥有 **96 KB** 的连续 SRAM，地址从 `0x2000 0000` 到 `0x2001 7FFF`。

### 4.1 特性
*   **零等待 (Zero Wait State)**: CPU 和 DMA 均可全速访问。
*   **无 CCM**: 与 F407 不同，F401 没有 Core Coupled Memory (CCM)。所有 96KB 内存均可被 DMA 访问，无需担心 DMA 无法访问栈变量的问题。
*   **掉电易失**: 复位或断电后数据丢失。

### 4.2 典型布局 (Memory Layout)
编译器（如 Keil/GCC）通常按以下顺序分配 SRAM：

1.  **.data**: 已初始化的全局变量/静态变量（启动时从 Flash 复制过来）。
2.  **.bss**: 未初始化的全局变量/静态变量（启动时清零）。
3.  **Heap (堆)**: 用于 `malloc`，向上生长。
4.  **Stack (栈)**: 用于局部变量和函数调用，从 SRAM 顶端 (`0x2001 7FFF`) 向下生长。

> **注意**: 必须确保 Heap 和 Stack 不会相遇（碰撞），否则会导致严重的系统崩溃。

---

## 5. 位带操作 (Bit-banding)

STM32F4 支持 Cortex-M4 的位带特性，允许通过一个普通的字（32位）写入操作，原子地修改某个比特位。

### 5.1 支持区域
1.  **SRAM 区**: `0x2000 0000` - `0x200F FFFF` (1MB)
2.  **外设区**: `0x4000 0000` - `0x400F FFFF` (1MB)

### 5.2 别名区 (Alias Region)
每个比特位在别名区膨胀为一个 32 位的字。
*   **SRAM 别名基地址**: `0x2200 0000`
*   **外设别名基地址**: `0x4200 0000`

**计算公式**:
```c
AliasAddr = AliasBase + (ByteOffset * 32) + (BitNumber * 4)
```

**应用场景**:
*   原子操作修改标志位（在中断和主循环共享变量时非常有用）。
*   GPIO 单个引脚的快速翻转（虽然操作 BSRR 寄存器更常用）。

---

## 6. 启动配置 (Boot Configuration)

STM32F401RET6 通过 `BOOT0` 和 `BOOT1` 引脚的状态决定复位后 CPU 从哪里获取第一条指令（映射到 `0x0000 0000`）。

| BOOT0 | BOOT1 | 启动模式 | 地址映射 (Aliasing) | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| **0** | X | **Main Flash Memory** | `0x0000 0000` 映射到 `0x0800 0000` | **最常用**。正常从 Flash 运行用户程序。 |
| **1** | 0 | **System Memory** | `0x0000 0000` 映射到 `0x1FFF 0000` | 运行出厂 Bootloader，用于串口/USB 下载程序。 |
| **1** | 1 | **Embedded SRAM** | `0x0000 0000` 映射到 `0x2000 0000` | 用于调试，直接在 RAM 中运行代码。 |

---

## 7. 总结

针对 **STM32F401RET6** 的开发建议：
1.  **内存规划**: 512KB Flash 空间充裕，但 96KB SRAM 相对宝贵。注意监控栈的使用量。
2.  **参数保存**: 利用 Sector 1 (16KB) 保存掉电不丢失参数，避免占用 Sector 4-7 等大扇区。
3.  **性能优化**: 务必在系统初始化时开启 Flash 预取和 ART 加速器，以发挥 84MHz 的全部性能。
4.  **DMA 使用**: 96KB SRAM 均支持 DMA，可以放心使用 DMA 搬运 ADC 数据或通信数据，减轻 CPU 负担。
