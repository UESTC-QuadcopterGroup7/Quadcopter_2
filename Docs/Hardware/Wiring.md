# STM32F401RE 接线引脚

## 遥控器接收机

| 接收机信号 | MCU 引脚 | 定时器通道 | 数据 | 默认功能 |
| --- | --- | --- | --- | --- |
| CH1 | PA0 | TIM2_CH1 | `PWM_IN_Wid[0]` | 横滚 |
| CH2 | PA1 | TIM2_CH2 | `PWM_IN_Wid[1]` | 俯仰 |
| CH3 | PB10 | TIM2_CH3 | `PWM_IN_Wid[2]` | 自动回中油门，回中停机 |
| CH4 | PB7 | TIM4_CH2 | `PWM_IN_Wid[3]` | 偏航 |
| GND | GND | | | |

引脚配置见 `Firmware/Drivers/Receive_IC.h` 和 `Firmware/Drivers/Receive_IC.c`。
通道分配及方向配置见 `Firmware/Control/RC_Config.h`，详细行为见 [遥控器到电机映射](../Control/遥控器到电机映射.md)。

## 电调

| 电调信号 | MCU 引脚 | 定时器通道 | 电机编号 | 机架位置 |
| --- | --- | --- | --- | --- |
| 电调 1 Signal | PA6 | TIM3_CH1 | 1 | 右后 |
| 电调 2 Signal | PA7 | TIM3_CH2 | 2 | 右前 |
| 电调 3 Signal | PB0 | TIM3_CH3 | 3 | 左前 |
| 电调 4 Signal | PB1 | TIM3_CH4 | 4 | 左后 |
| 各电调信号地 | GND | | | |

电机连接各自电调的三相输出，不直接连接 MCU。机头按 GY86 +X 正方向；PCB 槽位从左到右对应 M4 左后、M3 左前、M2 右前、M1 右后。左前已确认俯视 CW；混控要求右后 CW、右前/左后 CCW，其余三台仍需实测核对。引脚配置见 `Firmware/Drivers/BLDC.h`。

## OLED

| OLED 引脚 | MCU 引脚 |
| --- | --- |
| SCL | PC2 |
| SDA | PC3 |
| VCC | 3.3V |
| GND | GND |

引脚配置见 `Firmware/Drivers/OLED.c`。
