# STM32F401RET6 Bootloader Project

这是一个简易的 Bootloader 项目，用于演示如何从 Bootloader 跳转到 Application (App)。

## 项目结构
```
Bootloader/
├── Src/
│   └── main.c        # 核心逻辑：按键检测与跳转代码
└── Inc/
    └── (空)          # 头文件可复用主项目
```

## 核心功能
1.  **启动检查**：上电时检测按键状态（默认配置为 PC13，低电平有效）。
    *   **按下**：进入 Bootloader 维护模式（LED 慢闪，此处可扩展串口 IAP 功能）。
    *   **未按**：检查 App 地址合法性，跳转到 App 运行。
2.  **跳转逻辑**：
    *   关闭全局中断。
    *   获取 App 的 MSP（主堆栈指针）和 Reset_Handler 地址。
    *   重置 MSP 并跳转。

## 如何使用 Keil MDK 创建此项目

由于无法直接生成 `.uvprojx` 工程文件，请按照以下步骤在 Keil 中手动创建：

### 1. 新建工程
1.  打开 Keil uVision，点击 `Project` -> `New uVision Project`。
2.  保存路径选择 `d:\github\FourAxisProject\Quadcopter\DOCS\Startup\Bootloader`。
3.  设备选择：`STM32F401RETx`。

### 2. 配置运行环境 (RTE)
在 "Manage Run-Time Environment" 窗口中勾选：
*   **CMSIS** -> **CORE**
*   **Device** -> **Startup**

### 3. 添加源文件
在左侧 Project 窗口中：
1.  右键 `Source Group 1` -> `Add Existing Files to Group`。
2.  添加本项目生成的 `Src/main.c`。
3.  添加主项目的 HAL 库文件（位于 `../../../../Drivers/STM32F4xx_HAL_Driver/Src/`）：
    *   `stm32f4xx_hal.c`
    *   `stm32f4xx_hal_cortex.c`
    *   `stm32f4xx_hal_gpio.c`
    *   `stm32f4xx_hal_rcc.c`
4.  添加主项目的系统文件（位于 `../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Source/`）：
    *   `system_stm32f4xx.c`

### 4. 配置编译选项 (Options for Target)
1.  **C/C++ 选项卡** -> **Include Paths**，添加以下路径：
    *   `./Inc`
    *   `../../../../Inc`  (复用主项目的配置头文件)
    *   `../../../../Drivers/CMSIS/Include`
    *   `../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include`
    *   `../../../../Drivers/STM32F4xx_HAL_Driver/Inc`
2.  **C/C++ 选项卡** -> **Define**，添加：
    *   `USE_HAL_DRIVER`
    *   `STM32F401xE`
3.  **Target 选项卡** -> **IROM1** (Flash 布局)：
    *   **Start**: `0x8000000`
    *   **Size**: `0x4000` (16KB，作为 Bootloader 区域)

### 5. 编译与下载
1.  编译 Bootloader 并下载到开发板。
2.  **注意**：下载 Bootloader 会擦除 Sector 0。如果之前有 App，可能会被破坏，需要重新下载 App。

## 应用程序 (App) 的配合设置
你的 App 项目（主飞控代码）需要做如下修改才能被 Bootloader 引导：
1.  **IROM1 Start**: 修改为 `0x8004000`。
2.  **IROM1 Size**: 修改为 `0x7C000` (512KB - 16KB)。
3.  **SCB->VTOR**: 在 `main()` 开头添加 `SCB->VTOR = 0x08004000;`。
