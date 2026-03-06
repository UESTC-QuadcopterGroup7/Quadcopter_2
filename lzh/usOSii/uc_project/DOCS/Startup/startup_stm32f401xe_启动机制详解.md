# startup_stm32f401xe.s 启动机制详细讲解（STM32F401RE）

本文针对本工程的启动文件  
`Drivers/CMSIS/Device/ST/STM32F4xx/Source/startup_stm32f401xe.s`  
做逐段解析，目标是回答三个问题：

1. 上电后 CPU 第一条指令从哪里来？
2. 为什么还没进 `main()` 就能处理中断向量？
3. `SystemInit`、`__main`、`main` 三者分别负责什么？

---

## 1. 启动全流程（先看全局）

```text
上电/复位
  ↓
Cortex-M4 硬件自动读取地址 0x00000000 和 0x00000004
  ↓
MSP = 向量表[0] = __initial_sp
PC  = 向量表[1] = Reset_Handler
  ↓
执行 startup_stm32f401xe.s::Reset_Handler
  ↓
调用 SystemInit()  （system_stm32f4xx.c）
  ↓
跳转 __main        （C 运行时，完成 .data/.bss 初始化）
  ↓
进入用户 main()    （Src/main.c）
```

关键点：`startup_stm32f401xe.s` 不是“业务逻辑代码”，而是 C 程序启动前的“引导层”。

---

## 2. 栈与堆配置：程序运行的基础内存

启动文件开头先定义了栈和堆大小：

```assembly
Stack_Size      EQU     0x00000400
...
Heap_Size       EQU     0x00000200
```

- `Stack_Size = 0x400`，即 1024 字节
- `Heap_Size = 0x200`，即 512 字节

随后通过 `AREA` 和 `SPACE` 预留内存区：

```assembly
AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp
```

这里的 `ALIGN=3` 表示按 `2^3 = 8` 字节对齐，满足 ARM EABI 对栈对齐的要求。  
`__initial_sp` 标签会被写入向量表第 0 项，作为复位后 MSP 初值。

---

## 3. 中断向量表：地址 0 的“跳转目录”

向量表定义在 `RESET` 段中：

```assembly
AREA    RESET, DATA, READONLY
__Vectors       DCD     __initial_sp
                DCD     Reset_Handler
                DCD     NMI_Handler
                DCD     HardFault_Handler
                ...
                DCD     SysTick_Handler
                ; External Interrupts ...
```

理解方式：

- `DCD` 是“定义 32 位常量”（Define Constant Doubleword）
- 向量表本质是“函数地址数组”
- 第 0 项不是函数地址，而是栈顶地址
- 第 1 项是复位入口 `Reset_Handler`
- 后面每一项对应一个异常/中断入口

因此，中断触发时，内核只需按中断号索引此表，就能跳转到对应 ISR。

---

## 4. Reset_Handler：软件启动入口

本文件的核心代码非常短：

```assembly
Reset_Handler    PROC
                 IMPORT  SystemInit
                 IMPORT  __main

                 LDR     R0, =SystemInit
                 BLX     R0
                 LDR     R0, =__main
                 BX      R0
                 ENDP
```

执行语义：

1. `BLX SystemInit`  
   进入系统初始化（时钟/FPU/向量表重定位等底层初始化）
2. `BX __main`  
   跳入 C 运行时入口，不直接跳 `main`

为什么不是直接 `main`？  
因为 C 语言全局变量、静态变量、`.bss` 清零等工作都在 `__main` 里完成；不走这一步，C 环境不完整，程序会异常。

---

## 5. `__main` 做了什么（很多人最容易忽略）

`__main` 来自编译器运行时库，通常负责：

- 将 Flash 中的 `.data` 初值拷贝到 RAM
- 将 `.bss` 段清零
- 初始化 C/C++ 运行时环境
- 最终调用用户 `main()`

这解释了为什么“全局变量初值明明写了但不对”常常和启动链路有关。

---

## 6. 弱符号（WEAK）机制：默认中断与用户重写

启动文件中大量中断处理函数使用 `[WEAK]` 导出，例如：

```assembly
EXPORT  TIM2_IRQHandler  [WEAK]
...
TIM2_IRQHandler
    B .
```

`WEAK` 的意义：

- 启动文件提供“默认空实现”（死循环 `B .`）
- 如果用户在别的 C 文件里实现了同名强符号函数（如 `Src/stm32f4xx_it.c`），链接器会自动用用户版本覆盖默认版本

这就是为什么你只需要在 `stm32f4xx_it.c` 写 `TIM2_IRQHandler`，无需改启动文件。

---

## 7. Default_Handler：未实现中断的安全兜底

当某个中断已在向量表中声明、但项目里没有提供实际 ISR 时，会落到默认处理：

```assembly
Default_Handler PROC
...
                B       .
```

`B .` 是原地死循环，便于调试时快速发现“中断进了未实现入口”。  
实战中，如果程序“莫名卡死”，可优先检查是否进入了 `Default_Handler`。

---

## 8. Microlib 与非 Microlib：堆栈初始化分支

文件末尾有条件编译：

```assembly
IF :DEF:__MICROLIB
    EXPORT __initial_sp
    EXPORT __heap_base
    EXPORT __heap_limit
ELSE
    IMPORT __use_two_region_memory
    EXPORT __user_initial_stackheap
...
ENDIF
```

含义：

- 使用 Microlib 时，运行时直接使用导出的栈/堆边界符号
- 非 Microlib 时，需通过 `__user_initial_stackheap` 返回堆栈起止地址

这部分与工具链库模型相关，通常不需修改，但要知道它决定了运行时如何拿到堆栈布局。

---

## 9. 与本工程文件的关系（落到项目）

启动链路对应关系如下：

- `startup_stm32f401xe.s`  
  提供向量表 + `Reset_Handler`
- `system_stm32f4xx.c`  
  提供 `SystemInit`
- C 运行时库  
  提供 `__main`
- `Src/main.c`  
  用户应用入口 `main`
- `Src/stm32f4xx_it.c`  
  提供外设中断服务函数，覆盖 WEAK 默认实现

---

## 10. 常见问题与排查建议

### 10.1 程序上电后直接跑飞
- 检查向量表首地址是否正确映射
- 检查 `__initial_sp` 是否落在有效 SRAM 区间
- 检查链接脚本/散装文件与启动文件是否匹配芯片型号

### 10.2 进入 HardFault 后无法定位
- 在 `HardFault_Handler` 中增加寄存器现场导出
- 核查时钟初始化是否过早访问外设
- 核查中断是否在外设未完全初始化前被使能

### 10.3 中断函数不生效
- 检查函数名是否与启动文件向量表完全一致
- 检查是否被 `static` 修饰导致链接不可见
- 检查 NVIC 使能与中断优先级配置

---

## 11. 一句话总结

`startup_stm32f401xe.s` 的本质是：  
**在 C 代码运行前，建立“栈 + 向量表 + 复位入口 + 默认中断 + 运行时交接”的最小可执行启动框架。**  
理解它，能快速定位“上电不跑、进中断死机、全局变量异常”等底层问题。
