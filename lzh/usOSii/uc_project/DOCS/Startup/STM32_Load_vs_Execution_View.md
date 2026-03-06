# STM32 程序加载域与执行域详解 (Load View vs Execution View)

本文深入讲解 STM32 程序编译后在 **Flash (ROM)** 中的存储形态（加载域）与在 **RAM** 中运行时的形态（执行域）之间的区别，以及系统如何完成这两者之间的转换。

这是理解“为什么全局变量有初值”、“为什么程序烧录到 Flash 却能修改变量”的核心。

---

## 1. 核心概念定义

在 ARM Keil MDK 开发环境中，程序镜像（Image）由以下几个部分组成：

| 类型 | 全称 | 说明 | 示例 | 存储位置 |
| :--- | :--- | :--- | :--- | :--- |
| **Code** | Program Code | 编译后的机器指令 | `void main() { ... }` | Flash |
| **RO** | Read-Only Data | 只读常量 | `const int a = 10;`, `"Hello"` | Flash |
| **RW** | Read-Write Data | 已初始化且初值非 0 的变量 | `int count = 100;` | Flash (存初值) + RAM (运行时) |
| **ZI** | Zero-Initialized Data | 未初始化或初值为 0 的变量 | `int arr[100];`, `int flag = 0;` | RAM (运行时清零) |

### 1.1 加载域 (Load Region)
**程序“躺”在 Flash 里的状态**。也就是烧录文件（如 `.hex`, `.bin`）的内容。
*   **包含内容**：Code + RO + RW
*   **注意**：**不包含 ZI**。因为 ZI 全是 0，没必要浪费 Flash 空间存储，只需要记录它多大即可。

### 1.2 执行域 (Execution Region)
**程序“跑”在 CPU 里的状态**。也就是芯片上电运行时的内存分布。
*   **包含内容**：
    *   Flash 中：Code + RO
    *   RAM 中：RW + ZI

---

## 2. 内存视图对比 (The Two Views)

这是理解启动过程最经典的一张图：

```text
      【加载域 (Load View)】                  【执行域 (Execution View)】
       (程序烧录在 Flash 中)                   (程序运行时的 Flash + RAM)

+-----------------------------+           +-----------------------------+
|          RO (Code)          |           |          RO (Code)          |
|      (机器码 + 常量)        | --------> |      (机器码 + 常量)        |  <-- Flash (0x0800...)
+-----------------------------+           +-----------------------------+
|          RO (Data)          |           |          RO (Data)          |
+-----------------------------+           +-----------------------------+
|                             |
|       RW (Initial Values)   | \         +-----------------------------+
|      (变量的初始值)         |  \        |                             |
+-----------------------------+   \       |           RW Data           |  <-- RAM (0x2000...)
                                   \      |      (被复制过来的变量)     |
                                    \___> +-----------------------------+
                                          |                             |
                                          |           ZI Data           |
                                          |      (被自动清零的区域)     |
                                          +-----------------------------+
```

### 关键动作：
1.  **RO** (代码/常量)：原地不动，CPU 直接从 Flash 读取指令执行。
2.  **RW** (已初始化变量)：启动时，需要从 Flash **复制** 到 RAM。
    *   *为什么？* 因为 Flash 是只读的，而变量需要修改。所以必须把“初值”搬到“可读写内存”里。
3.  **ZI** (零初始化变量)：启动时，直接在 RAM 中划出一块区域，**全部清零**。

---

## 3. 谁来完成这个“搬运”工作？

这个过程称为 **分散加载 (Scatter Loading)**。

在 `startup_stm32f401xe.s` 中：
```assembly
Reset_Handler    PROC
                 ...
                 LDR     R0, =__main  ; 调用 C 库入口
                 BX      R0
```

**`__main` 函数** (C Library Entry) 是幕后英雄，它会执行以下步骤：
1.  读取链接器生成的“分散加载表”（Scatter-loading description）。
2.  **Copy RW**：将 RW 数据从 Flash 地址复制到 RAM 目标地址。
3.  **Zero ZI**：将 RAM 中紧接在 RW 之后的一段内存清零，作为 ZI 区。
4.  初始化堆栈。
5.  跳转到用户的 `main()`。

---

## 4. 空间占用计算公式

当我们编译完 Keil 工程后，Build Output 窗口会显示：

```text
Program Size: Code=4684 RO-data=268 RW-data=44 ZI-data=1628
```

如何解读这个数据？

### 4.1 烧录到 Flash 的大小 (ROM Size)
芯片 Flash 空间至少需要多大？
> **ROM Size = Code + RO_data + RW_data**

*   `ZI_data` 不占 Flash 空间（只占 RAM）。
*   注意：`RW_data` 虽然是变量，但它的**初值**必须存在 Flash 里，否则断电就丢了。

### 4.2 运行时占用的 RAM 大小 (RAM Size)
芯片 SRAM 空间至少需要多大？
> **RAM Size = RW_data + ZI_data**

*   `Code` 和 `RO_data` 通常直接在 Flash 运行，不占 RAM（除非为了速度特意拷贝到 RAM 执行）。
*   `RW_data` 在 RAM 占一份（用于读写），在 Flash 占一份（用于存初值）。

---

## 5. 实例分析

假设有以下 C 代码：

```c
const int table[4] = {1, 2, 3, 4};  // RO-data (存 Flash)
int global_x = 100;                 // RW-data (存 Flash 初值 -> 搬运到 RAM)
int global_y = 0;                   // ZI-data (RAM 清零)
int buffer[100];                    // ZI-data (RAM 清零)

void main() {
    global_x++;  // 修改 RAM 中的 global_x
}
```

**编译后的内存行为**：

1.  **Flash (加载域)**：
    *   存放 `table` 的值 `1, 2, 3, 4`。
    *   存放 `global_x` 的初值 `100`。
    *   **不存放** `global_y` 和 `buffer` 的值。

2.  **启动过程 (`__main`)**：
    *   从 Flash 读取 `100`，写入到 RAM 中 `global_x` 的地址。
    *   将 RAM 中 `global_y` 和 `buffer` 的地址范围填 `0`。

3.  **main() 运行**：
    *   CPU 读取 RAM 中的 `global_x` (此时是 100)，加 1，写回 RAM (变成 101)。
    *   Flash 中的 `100` 保持不变（用于下次复位后恢复初值）。

---

## 6. 进阶：如何自定义加载域？ (Linker Script / Scatter File)

如果想把代码也放到 RAM 里跑（比如为了提升速度，或者 Flash 要进行擦写操作），就需要修改 **分散加载文件 (.sct)**。

典型的 STM32 Scatter File (`.sct`) 结构：

```text
LR_IROM1 0x08000000 0x00080000  {    ; 加载域：从 Flash 起始
  ER_IROM1 0x08000000 0x00080000  {  ; 执行域 1：Code + RO 仍在 Flash
   *.o (RESET, +First)
   *(InRoot$$Sections)
   .ANY (+RO)
  }
  RW_IRAM1 0x20000000 0x00018000  {  ; 执行域 2：RW + ZI 在 RAM
   .ANY (+RW +ZI)
  }
}
```

*   **LR_IROM1** (Load Region): 定义 Flash 里的整个镜像。
*   **ER_IROM1** (Execution Region 1): 定义代码段在 Flash 原地执行。
*   **RW_IRAM1** (Execution Region 2): 定义数据段被搬运到 RAM `0x20000000` 处。

---

## 7. 总结

1.  **加载域 (Flash)** = Code + RO + RW
2.  **执行域 (Flash + RAM)** = (Code + RO) + (RW + ZI)
3.  **启动魔法**：`__main` 负责把 RW 从 Flash 搬到 RAM，把 ZI 清零。
4.  **占用计算**：
    *   Flash 占用 = Code + RO + RW
    *   RAM 占用 = RW + ZI
