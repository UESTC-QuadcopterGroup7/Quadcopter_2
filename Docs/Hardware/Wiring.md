# STM32F401RE 接线引脚

## 遥控器接收机

| 接收机信号 | MCU 引脚 | 定时器通道 | 数据 |
| --- | --- | --- | --- |
| CH1 | PA0 | TIM2_CH1 | `PWM_IN_Wid[0]` |
| CH2 | PA1 | TIM2_CH2 | `PWM_IN_Wid[1]` |
| CH3 | PB10 | TIM2_CH3 | `PWM_IN_Wid[2]` |
| CH4 | PB7 | TIM4_CH2 | `PWM_IN_Wid[3]` |
| GND | GND | | |

引脚配置见 `MyLib/Receive_IC.h` 和 `MyLib/Receive_IC.c`。

## 电调

| 电调信号 | MCU 引脚 | 定时器通道 | 电机编号 |
| --- | --- | --- | --- |
| 电调 1 Signal | PA6 | TIM3_CH1 | 1 |
| 电调 2 Signal | PA7 | TIM3_CH2 | 2 |
| 电调 3 Signal | PB0 | TIM3_CH3 | 3 |
| 电调 4 Signal | PB1 | TIM3_CH4 | 4 |
| 各电调信号地 | GND | | |

电机连接各自电调的三相输出，不直接连接 MCU。编号对应程序通道，不代表机架位置或旋向。引脚配置见 `MyLib/BLDC.h`。

## OLED

| OLED 引脚 | MCU 引脚 |
| --- | --- |
| SCL | PC2 |
| SDA | PC3 |
| VCC | 3.3V |
| GND | GND |

引脚配置见 `MyLib/OLED.c`。
