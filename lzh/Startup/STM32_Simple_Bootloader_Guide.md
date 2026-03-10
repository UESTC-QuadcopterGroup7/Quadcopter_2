# STM32 简易 Bootloader 开发指南

本文将带你编写一个最简单的 STM32 Bootloader，用于理解 Bootloader 跳转到应用程序（App）的核心原理。

## 1. 原理图解

我们将 Flash 划分为两个区域：

- **Bootloader 区**：`0x0800 0000` \~ `0x0800 3FFF` (16KB)
- **App 区**：`0x0800 4000` \~ `Flash End`

```text
+-----------------------+ 0x0800 0000 (Bootloader Start)
|                       |
|   Bootloader Code     |
|                       |
+-----------------------+ 0x0800 4000 (App Start)
|   (Vector Table)      | <--- App 的中断向量表在这里
|                       |
|   Application Code    |
|                       |
+-----------------------+
```

## 2. Bootloader 核心代码

Bootloader 的主要任务是：**检查是否需要进入升级模式，否则跳转到 App。**

新建一个工程，`main.c` 核心逻辑如下：

```c
#include "stm32f4xx_hal.h"

// 定义 App 的起始地址 (必须是 0x200 的倍数，参考中断向量表对齐要求)
#define APP_ADDRESS     (0x08004000)

// 定义函数指针类型
typedef void (*pFunction)(void);

// 跳转函数
void JumpToApplication(void)
{
    uint32_t JumpAddress;
    pFunction JumpToApplicationFn;

    // 1. 检查 App 地址是否合法 (检查栈顶地址是否在 SRAM 范围内)
    // *(__IO uint32_t*)APP_ADDRESS 取出的是 App 向量表的第 0 项 (MSP 初始值)
    // STM32F401RE SRAM 范围: 0x20000000 ~ 0x20018000 (96KB)
    if (((*(__IO uint32_t*)APP_ADDRESS) & 0x2FF00000) == 0x20000000)
    {
        // 2. 关闭所有中断 (非常重要！否则跳转后 App 收到中断会跑飞)
        __disable_irq();
        
        // 3. 获取 App 的复位中断处理函数地址 (向量表第 1 项)
        JumpAddress = *(__IO uint32_t*)(APP_ADDRESS + 4);
        JumpToApplicationFn = (pFunction)JumpAddress;

        // 4. 设置主堆栈指针 (MSP) 为 App 的栈顶
        __set_MSP(*(__IO uint32_t*)APP_ADDRESS);

        // 5. 跳转到 App
        JumpToApplicationFn();
    }
    else
    {
        // App 地址非法，死循环闪灯报错
        while(1) {
            HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5); // 假设 LED 在 PA5
            HAL_Delay(100);
        }
    }
}

int main(void)
{
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init(); // 初始化按键 GPIO

    // 检测按键 (假设按键在 PC13，按下为低电平)
    // 如果按住按键启动，则停留在 Bootloader (闪灯)
    if (HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_13) == GPIO_PIN_RESET)
    {
        while (1)
        {
            // 进入 Bootloader 模式 (此处可添加串口 IAP 代码)
            HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
            HAL_Delay(500); 
        }
    }

    // 否则跳转到 App
    JumpToApplication();

    while (1);
}
```
## 3. 启动流程
当单片机上电时，一切都从 Flash 的起始地址 0x0800 0000 开始。
### 阶段一：硬件复位 (Reset)
1. MSP 初始化 ：CPU 从 0x0800 0000 读取第一个字，作为主堆栈指针 (MSP) 的初始值。
2. Reset Handler ：CPU 从 0x0800 0004 读取第二个字，这是 Bootloader 的 Reset_Handler 函数地址。
3. 跳转执行 ：CPU 跳转到 Bootloader 的 Reset_Handler 
### 阶段二：Bootloader 运行
4. SystemInit ：配置时钟，初始化 C 库环境。
5. main() ：
   - 硬件初始化 ：初始化 HAL 库、GPIO（LED 和按键）。
   - 按键检测 ：
     - 如果按住按键 -> 进入死循环 (Loader 模式) ，LED 快速闪烁。
     - 如果松开按键 -> 准备跳转 。
###  阶段三：准备跳转 (JumpToApplication)
6. 合法性检查 ：读取 App 地址 ( 0x0800 4000 ) 处的第一个字，检查是否为有效的栈地址（判断是否在 SRAM 范围内）。
7. 环境清理 ：
   - __disable_irq() ： 关中断 （非常关键！防止跳转途中触发中断导致跑飞）。
   - HAL_DeInit() ：关闭所有外设时钟，复位外设状态。
   - SysTick->CTRL = 0 ：关闭系统滴答定时器。
8. 获取 App 信息 ：
   - 从 0x0800 4004 读取 App 的 Reset_Handler 地址。
9. 切换环境 ：
   - SCB->VTOR = 0x0800 4000 ：告诉 CPU，以后的中断向量表在 App 那里（这步也可以在 App 启动后做）。
   - __set_MSP(...) ：将栈指针切换为 App 的栈。
### 阶段四：App 启动
10. 跳转 ：CPU 跳转到 App 的 Reset_Handler 。
11. App 初始化 ：
    - App 再次执行 SystemInit 。
    - 再次设置 VTOR ： SCB->VTOR = 0x0800 4000 （双重保险，App 必须知道自己的向量表在哪里）。
    - __enable_irq() ：重新开启中断。
12. App 运行 ：执行 App 的 main() ，就像没有 Bootloader 一样。

## 4. 应用程序 (App) 的修改

为了让 App 能在 `0x0800 4000` 运行，你需要做两件事：

### 4.1 修改链接地址 (Keil 设置)

1. 打开 App 工程的 **Options for Target** -> **Target** 选项卡。
2. 修改 **IROM1**：
   - Start: `0x8004000` (原为 0x8000000)
   - Size: `0x7C000` (原为 0x80000 - 0x4000)

### 4.2 重定向中断向量表 (SCB->VTOR)

在 App 的 `main()` 函数**最开始**（或者 `SystemInit` 中），必须重新设置向量表偏移量。

```c
int main(void)
{
    // 重要！告诉 CPU 中断向量表现在位于 0x08004000
    // 否则发生中断时，CPU 还是会去查 0x08000000 处的表
    SCB->VTOR = 0x08004000; 

    HAL_Init();
    // ... 其他代码
}
```

> **注意**：在 `system_stm32f4xx.c` 中，`SystemInit` 函数通常也会设置 VTOR。你可以直接修改那里的宏定义 `VECT_TAB_OFFSET` 为 `0x4000`。

## 5. 常见坑点

1. **中断未关闭**：跳转前必须 `__disable_irq()`。App 初始化时再 `__enable_irq()`。如果跳转瞬间发生中断，CPU 会去查旧的向量表，导致崩溃。
2. **外设未复位**：最好在跳转前调用 `HAL_DeInit()`，将用过的 GPIO、UART 等复位到默认状态，避免干扰 App 初始化。
3. **栈顶地址检查**：代码中的 `if (((*(__IO uint32_t*)APP_ADDRESS) & 0x2FF00000) == 0x20000000)` 是为了防止跳转到空 Flash 导致 HardFault。
4. **Keil 下载设置**：
   - 烧录 Bootloader 时：选择 "Erase Sectors"（不要全片擦除）。
   - 烧录 App 时：同样选择 "Erase Sectors"，Keil 会自动只擦除 0x8004000 后的区域，保留 Bootloader。

## 6. 总结

编写 Bootloader 的本质就是：

1. **规划地盘**：Flash 分区。
2. **让路**：Bootloader 运行完后，把控制权交给 App。
3. **指路**：告诉 CPU 新的“地图”（VTOR）在哪里。

