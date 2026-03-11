docker run -it --name stm32_build -v ${PWD}:/work -w /work stm32_build bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi

sudo apt-get install -y --no-install-recommends gdb-multiarch
sudo apt-get install -y --no-install-recommends openocd

arm-none-eabi-gcc --version
arm-none-eabi-ld --version
cmake --version
make --version
gdb-multiarch --version
openocd --version

點燈工程 操作PA5引脚

要操作的寄存器
+ RCC時鐘使能
- RCC_AHB1ENR=0x40023830
- bit0=GPIOAEN(1)
+ GPIOA模式寄存器 MODER
- GPIO_MODER=0x40020000 [11:10]=01
+ GPIOA輸出數據寄存器
- GPIOA_ODR=0x40020014 

上电 / 复位
→ CPU 读取向量表第 0 项
→ 把它装进 SP（栈指针）
→ CPU 读取向量表第 1 项
→ 跳转到 Reset_Handler
→ Reset_Handler 做运行前初始化
→ 调用 main
→ main 开始执行业务代码

所以 startup.s 的职责，本质上就 3 件事：
放中断向量表
提供 Reset_Handler
在 Reset_Handler 里跳到 main

MSP 主棧指針 PSP 進程棧指鍼
在Cortex-M裏 程序啓動時CPU默認去地址
+ 0x08000000 獲取中斷向量表
先連續讀相鄰二處地址 (每次讀取32位字 即四個字節)
- 第0項 0x08000000 初始棧頂指針 CPU把值送入SP/MSP
由CONTROL寄存器的SPSEL位(mux多路選擇器)決定當前SP是MSP還是PSP
1. CONTROL.SPSEL=0 使用MSP
2. CONTROL.SPSEL=1 使用PSP
即CONTROL[1]=0 使用MSP CONTROL[1]=1 使用PSP
但是 Handler mode(異常/中斷)下强制使用MSP
Thread mode(綫程模式)下才可以選擇使用PSP還是MSP
- 第1項 Reset_Handler 入口地址

Cortex-M的内存分區
Cortex-M儘管顯示是統一連續的内存空間 但是不同區段鏈接不同類型的存儲躰或硬件模塊
1. 主flash 0x8000000~0x0807FFFF 
2. SRAM 0x20000000~0x20017FFF
3. System memory 系統存儲器 ST Bootloader 0x1FFF0000~0x1FFF7A0F
4. Option bytes 0x1FFFC000~0x1FFFC007

STM32F401 支持三种启动来源：
从 Main Flash 启动
从 System memory 启动
从 Embedded SRAM 启动

芯片里真实有几块固定的物理存储：
主 Flash 在 0x08000000
System Memory 在 0x1FFF0000
SRAM 在 0x20000000
但 Cortex-M 复位时，向量表入口固定看 0x00000000
所以 STM32F401 做了一个“启动窗口”：
把 某一块物理存储内容，别名 到 0x00000000

启动时由 boot pins 选择三种 boot option 之一：
user flash memory / system memory / embedded SRAM

A. Boot from user flash memory
这是最正常、最常见的启动方式。
意思是：
把 主 Flash 映射到 0x00000000
所以 CPU 复位后从 0x00000000 读到的，其实就是主 Flash 开头那张向量表
这张表在物理上本来位于 0x08000000 开始的 Flash。
也就是说此时：
逻辑 0x00000000  --->  物理主Flash 0x08000000
逻辑 0x00000004  --->  物理主Flash 0x08000004
B. Boot from system memory
把System Memory映射到0x00000000
CPU 复位后进入的是 ST 预先烧在系统存储器里的 bootloader，而不是你的用户程序
STM32F401 的系统 bootloader 位于 system memory，用于通过 USART、USB DFU、I2C、SPI 等接口重编程 Flash
逻辑 0x00000000  --->  物理System Memory 0x1FFF0000
C. boot from embedded SRAM
把SRAM映射到0x00000000
CPU復位后把SRAM開頭内容儅向量表來讀

就是說CPU首先讀取邏輯上的0x00000000作爲入口邏輯地址

STM32F401 的 SYSCFG_MEMRMP.MEM_MODE 位可以控制 0x00000000 的 memory mapping；而且该字段复位后的值来自 Boot pins
其定义就是：
00：Main Flash mapped at 0x00000000
01：System Flash mapped at 0x00000000
11：Embedded SRAM mapped at 0x00000000

复位刚结束时：由 Boot pins 决定
程序运行起来后：软件还能改映射

如果 BOOT 配置成 Flash 启动，那么复位时硬件会让：
0x00000000 -> alias 到 0x08000000
0x00000004 -> alias 到 0x08000004

启动映射由 Boot pins 决定复位后的 memory mapping 初值
SYSCFG_MEMRMP.MEM_MODE 的复位值来自 Boot pins
这个映射可以让 0x00000000 对应到：
Main Flash
System Flash / System memory
Embedded SRAM

发生复位
-> 芯片释放复位前/复位释放时采样 Boot 配置
-> 设置 0x00000000 的启动映射
-> Cortex-M 从 0x00000000 取 MSP 和 Reset 向量
-> 跳到 Reset_Handler
-> 启动代码运行
-> main()

BOOT=00
0x00000000映射到Main Flash 
CPU讀取二個字為MSP Reset_Handler
BOOT=01
0x00000000映射到System Memory
CPU先讀取的二個字為MSP ST BootLoader入口地址
BOOT=11
CPU讀取二個字為MSP Reset入口地址

复位
-> 硬件装载 MSP
-> 硬件跳到 Reset_Handler
-> Reset_Handler 调用 SystemInit
-> 拷贝 .data 到 RAM
-> 清零 .bss
-> 调用 __libc_init_array（若使用C/C++运行库）
-> 调用 main()

第一步：硬體先裝載 MSP
Cortex-M 在復位時會先從向量表取值。向量表的第一項是初始堆疊指標值，所以硬體先把它裝入 MSP；第二項是 Reset 向量，硬體再把它裝入 PC，從那個地址開始執行。ARM/STM32 的官方文件都把這個行為列為 Cortex-M 啟動的基本機制
也就是：
[向量表 + 0x00] -> MSP
[向量表 + 0x04] -> PC (Reset_Handler)
第二步：硬體跳到 Reset_Handler
把 PC 裝好之後，CPU 就開始執行 Reset_Handler。到這一步為止，還屬於**“剛啟動，先把第一段軟體拉起來”**。
第三步：Reset_Handler 做啟動初始化
這時才輪到啟動檔中的程式碼工作。典型順序是：
呼叫 SystemInit()
將 .data 從 Flash 複製到 RAM
將 .bss 清零
視工具鏈呼叫 __libc_init_array() 等 C/C++ 執行環境初始化
呼叫 main()。
「硬體裝載 MSP 後又幹了什麼」，最簡答案就是：
硬體接著裝載 Reset 向量到 PC，跳進 Reset_Handler；然後由 Reset_Handler 去做 SystemInit()、初始化 .data/.bss，最後才進 main()

make -f Makefile.stm32f401
make -f Makefile.stm32f401 clean
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "program build_stm32f401/stm32f401_blink_pa5.elf verify reset exit"
