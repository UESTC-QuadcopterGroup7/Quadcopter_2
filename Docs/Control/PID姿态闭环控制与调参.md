# PID 姿态闭环控制与调参

本项目已将遥控器、电机混控与 GY86 反馈接成闭环：横滚、俯仰采用角度 P 外环和角速度 PID 内环，偏航采用角速度 PID。代码默认启用，已加入 `LED.uvprojx`，由原来的 `AppTaskControl` 驱动。

默认增益是用于开始验证的初始值，尚未针对实际机架、电机、桨和电调整定。编译和模型测试证明代码的方向、计算和保护逻辑，不代表实机已经达到某种跟踪精度或具备直接试飞条件。

## 1. 操作行为

| 通道 | 目标 | 松杆回中后的行为 |
| --- | --- | --- |
| CH1 横滚 | -20°～+20°，右滚为正 | 油门有效时回到水平横滚目标 |
| CH2 俯仰 | -20°～+20°，抬头为正 | 油门有效时回到水平俯仰目标 |
| CH3 油门 | 中点以上半程映射 0～1 | **停机**，不保留高度或悬停油门 |
| CH4 偏航 | -90°/s～+90°/s，右转为正 | 目标转速为 0；抑制旋转，不锁定绝对航向 |

保留之前的自动回中油门规则：CH3 的 1000～1520 μs 为停止，1520～2000 μs 逐渐增加油门。其他三路的 1480～1520 μs 为死区，通道及方向仍在 [RC_Config.h](../../Firmware/Control/RC_Config.h) 中配置。

四台电机的位置不变：M1 右后、M2 右前、M3 左前、M4 左后；PCB 槽位从左到右是 M4、M3、M2、M1。偏航混控按左前 CW、右后 CW、右前 CCW、左后 CCW 配置，其中左前 CW 已由实物确认，其余三台仍需核对。

## 2. 接入位置与数据流

```text
接收机 PWM → IC_GetSnapshot → RC_Decode / RC_MakeSetpoint / 解锁状态
                                      ↓
GY86 → 偏置补偿 → Madgwick → 角度外环 P → 三轴目标机体角速度
  └──────── 补偿后的陀螺反馈 ────────────→ 三轴角速度 PID
                                             ↓
                                      RC_Mix → M1..M4
                                             ↓
                                      BLDC_SetThrottle_us
```

| 文件 | 职责 |
| --- | --- |
| [PID.c / PID.h](../../Firmware/Algorithms/PID.h) | 通用 PID，测量微分、低通、条件积分与执行器回算 |
| [FlightControl.c / FlightControl.h](../../Firmware/Control/FlightControl.h) | 反馈检查、外环、三轴内环、停机及混控 |
| [FlightControlConfig.h](../../Firmware/Control/FlightControlConfig.h) | PID 增益、滤波、时序和倾角限制 |
| [RC_Control.c](../../Firmware/Control/RC_Control.c) | 遥控解码、目标生成和手势；单独调用不再生成电机差速 |
| [ReadPeripherals.c](../../Firmware/Services/ReadPeripherals.c) | 发布同一采样的姿态、角速度、有效标志和时间戳 |
| [main.c](../../Src/main.c) | 每 5 ms 读取快照，调用闭环并写四路电调 |

`FC_Control_Init(&control, SystemCoreClock)` 接收 DWT 计数器频率。周期调用：

```c
IC_GetSnapshot(&input);
ReadPeripherals_GetControlFeedback(&feedback);
FC_Control_Update(&s_flight_control, &input, &feedback, HAL_GetTick());
/* s_flight_control.rc.motor_us[0..3] 分别写到 BLDC idx 1..4。 */
```

控制模块不访问 HAL、RTOS 或堆内存，能够在电脑上直接测试。实际 HAL/RTOS 采样和电机写入留在现有驱动与任务中。

## 3. 角度、角速度与电机方向

机体坐标沿用 [Quaternion.h](../../Firmware/Algorithms/Quaternion.h)：X 向前、Y 向左、Z 向上。显示角度和混控约定为右滚、抬头、右转为正，因此不能把陀螺三个原始值直接当成相同符号的控制反馈：

| 控制反馈 | 原始 MPU6050 计数换算 |
| --- | --- |
| 右滚角速度 | `gx / 16.4` |
| 抬头角速度 | `-gy / 16.4` |
| 右转角速度 | `-gz / 16.4` |

16.4 LSB/(°/s) 对应当前 `GYRO_CONFIG=0x18` 的 ±2000°/s 量程，统一定义在 `GY86.h`。改变陀螺量程时，必须同时修改寄存器配置和该比例。

角度外环先计算：

```text
roll_dot  = clamp(Kp_angle_roll  × (roll_target  - roll_measured),  ±120)
pitch_dot = clamp(Kp_angle_pitch × (pitch_target - pitch_measured), ±120)
yaw_dot   = yaw_rate_target
```

欧拉角速度与机体角速度在倾斜后并不相同。`RateTargets()` 按现有 `Rz(-yaw) × Ry(-pitch) × Rx(roll)` 约定转换，以下三角函数中的 φ、θ 是以 rad 表示的实测横滚、俯仰：

```text
roll_rate_target  = roll_dot - yaw_dot × sin(θ)
pitch_rate_target = pitch_dot × cos(φ) + yaw_dot × sin(φ) × cos(θ)
yaw_rate_target   = -pitch_dot × sin(φ) + yaw_dot × cos(φ) × cos(θ)
```

转换后横滚、俯仰目标机体角速度限制为 ±120°/s，偏航限制为 ±90°/s。

每个角速度 PID 输出一项 μs 修正，继续使用原来的 X 架公式：

```text
M1 右后 = T - R - P - Y
M2 右前 = T - R + P + Y
M3 左前 = T + R + P - Y
M4 左后 = T + R - P + Y
```

这里的 R/P/Y 来自 PID，不再是摇杆位置乘固定差速。目标为水平时，右滚 10° 应产生负 R，右侧电机输出高于左侧；抬头 10° 应产生负 P，后侧输出高于前侧；正在右转且偏航目标为 0 时，应增加 CW 对角电机的输出以制动。

## 4. PID 实现

设目标角速度为 r，滤波后的实测角速度为 y，时间间隔 dt 单位为 s：

```text
e = r - y
P = Kp × e
I_candidate = clamp(I_previous + Ki × e × dt, ±I_limit)
D = -Kd × LPF((y - y_previous) / dt)
output = clamp(P + I + D, ±output_limit)
```

D 对测量值微分，摇杆目标阶跃不会直接产生 D 冲击；首次更新只初始化微分历史。陀螺反馈先经过 30 Hz 一阶低通，测量微分再经过 10 Hz 一阶低通，滤波系数均按实际 dt 计算。

积分采用以下约束：

- I 项自身限幅。
- 输出饱和时拒绝使饱和更严重的积分，允许反向退饱和。
- 归一化油门低于 0.10 时冻结积分；油门回中、上锁或故障时清空积分、微分历史和滤波状态。
- 混控后从四路 PWM 反算实现的 R/P/Y，若混控缩小差速，用 `PID_TrackOutput()` 回算积分，避免执行器做不到而积分继续增长。忽略不超过 0.5 μs 的取整误差。

## 5. 时间、反馈和保护

姿态和陀螺反馈必须来自同一次采集。`PublishAttitude()` 先在局部结构体组装，再在临界区内整体发布；读取端也复制完整快照，避免高优先级控制任务抢占到一半的写入。

| 反馈字段 | 用途 |
| --- | --- |
| `valid` | 校准完成、本次读取/解算成功，陀螺未接近饱和 |
| `timestamp_ms` | 用 `HAL_GetTick()` 检查反馈年龄 |
| `timestamp_cycles` | 用 DWT 周期计数差分计算实际 PID dt |
| `sequence` | 软件采集/解算发布序号，防止同一快照被重复积分 |

只有新序号到达时才推进外环、滤波和 PID；重复快照保留修正量，并应用当前油门。`sequence` 不是 MPU6050 硬件数据就绪计数。首次启动闭环使用 5 ms 初始化步长，后续使用实际消费的样本间隔：

```text
dt = (uint32_t)(current_cycles - previous_cycles) / SystemCoreClock
```

先做无符号减法再换算为秒，允许 DWT 计数器自然回绕。控制任务仍是约 200 Hz，IMU 配置输出率为 200 Hz，电调 PWM 仍是 **50 Hz**。任务算得更快不会提高电调接收命令的频率；50 Hz 输出及电机延迟限制实际可用带宽，增益不能直接照搬高速 ESC 的飞控。确认电调支持的协议和频率后，再单独调整输出驱动。

以下情况会输出 1000 μs 并上锁：

| 条件 | 状态码 |
| --- | --- |
| 任一遥控通道无效或达到 100 ms 未更新 | `FC_STATUS_RC_LOST`，3 |
| 反馈无效、NaN/Inf、角速度异常，或采集失败 | `FC_STATUS_FEEDBACK_INVALID`，4 |
| 反馈达到 30 ms 未更新 | `FC_STATUS_FEEDBACK_STALE`，5 |
| 解锁时总倾角超过 15° | `FC_STATUS_ARM_TILT`，6 |
| 总倾角达到或超过 70°，或翻转故障尚未解除 | `FC_STATUS_EXCESS_TILT`，7 |
| 连续有效控制的样本间隔小于 1 ms 或大于 25 ms | `FC_STATUS_BAD_TIMING`，8 |
| PID 输入/计算非法 | `FC_STATUS_PID_ERROR`，9 |

正常状态为 `DISARMED=0`、`ACTIVE=1`、`THROTTLE_OFF=2`。油门回中会停机并复位 PID，但保留解锁状态；上述故障会额外上锁，恢复后必须重新执行手势。翻转故障还会锁存，必须先按下述步骤解除。达到 70° 即停机的设置使本实现面向小倾角姿态控制，不适用于翻滚特技。

### 翻转停机与故障解除

总倾角是机体向上轴与大地向上轴的夹角：水平为 0°，侧立为 90°，完全倒扣为 180°。由融合后的姿态计算：

```text
cos(total_tilt) = cos(roll) * cos(pitch)
```

因此横滚 60°、俯仰 60° 的合成倾角约为 75.5°，也会停机；检测不会遗漏两个单轴都未达到 70° 的情况。这里使用姿态解算结果，不依据瞬时加速度 Z 的正负判定翻转。

总倾角达到 `FC_STOP_MAX_TILT_DEG`（默认 70°）后，控制任务当次即输出四路 1000 μs、清空 PID 并上锁，`tipover_latched` 置 1。扶正、信号恢复或高油门都不会清除该标志，普通遥控上锁操作也不会绕过它。

恢复操作：

1. 将飞机扶正，总倾角不超过 `FC_ARM_MAX_TILT_DEG`（默认 15°），确保姿态与遥控信号有效。
2. 油门回中、横滚/俯仰居中，偏航左打满连续保持 `FC_TIPOVER_CLEAR_HOLD_MS`（默认 1 秒）。中途松开手势、超过允许倾角或反馈/遥控异常都会重新计时。
3. 故障解除后仍为上锁状态，四路继续输出停止值。偏航先回中，再右打满保持 1 秒重新解锁，随后才可增加油门。

这属于电机停机指令，不能切断电池供电，也不会停止 MCU 的监测和调试功能。电调 PWM 为 50 Hz，停止指令在后续 PWM 周期生效，转子仍需要时间消除惯性。该保护依赖正确且持续更新的姿态估计，必须水平静止上电校准；程序卡死或 HardFault 不能靠此控制任务内的保护处理。

`MPU6050_GetData()` 现在返回成功/失败状态，读取失败不再解码未初始化缓冲区，也不会推进偏置校准或发布新的有效控制反馈。接收机若在无线失联后持续输出旧的有效 PWM，仍需在接收机端配置 CH3 失控回中。

## 6. 参数表

全部初始参数位于 [FlightControlConfig.h](../../Firmware/Control/FlightControlConfig.h)，改动后重新编译。

| 参数 | 横滚 / 俯仰 | 偏航 | 单位 |
| --- | --- | --- | --- |
| 角度外环 Kp | 4.0 / 4.0 | 不使用角度外环 | (°/s)/° |
| 角速度 Kp | 0.88 / 0.88 | 1.00 | μs/(°/s) |
| 角速度 Ki | 0.25 / 0.25 | 0.20 | μs/° |
| 角速度 Kd | 0.005 / 0.005 | 0 | μs/(°/s²) |
| I 项限幅 | ±50 | ±40 | μs |
| PID 输出限幅 | ±200 | ±120 | μs |

代码中的 Ki 已乘 dt，Kd 已除 dt，不能在参数中再补乘或除一次采样周期。外环使用 P 的原因是将角度误差转换成转速目标，由内环 PID 负责跟踪和消除持续转矩偏差。

## 7. 调试与整定顺序

1. 拆掉全部螺旋桨，水平静止上电。等待原有 5 秒电调初始化，以及随后约 1 秒的陀螺偏置校准完成；没有有效姿态时不能解锁。
2. 核对四个槽位、电机实际旋向、遥控方向及姿态显示。油门回中、横滚/俯仰居中，偏航右打满保持 1 秒解锁。偏航松回中后再缓慢增加油门。
3. 油门有效时小角度倾斜机体，检查第 3 节所列的纠偏方向；电机应产生把倾斜推回目标的差速。方向不对时先修正传感器/电机映射，不能通过负增益弥补。
4. 拆桨检查只能确认方向、限幅和停机逻辑。需要实际转动响应才能整定增益；采用能约束被测轴、保证桨叶运动空间的测试装置，先整定角速度内环，再整定角度外环。
5. 每次只改一个轴的一项参数。内环可先将 Ki/Kd 暂设 0，从较小 Kp 开始观察响应；过冲或持续振荡时减小 Kp，再逐步加入 D 改善阻尼，最后加 I 修正持续偏差。增加 D 后同时观察噪声和电机发热。外环调整 Kp，使回正响应合适且不要求超出内环能力的转速。
6. 每次改动记录目标、测量、P/I/D、输出、dt 和现象；同时验证回中停机、偏航左打满 1 秒上锁，以及输入或传感器异常后的停机与重新解锁。

调试器重点观察 `s_flight_control`：

| 成员 | 含义 |
| --- | --- |
| `rc.command` / `rc.setpoint` | 归一化遥控量与角度/角速度目标 |
| `rc.armed` / `status` | 解锁状态和保护原因 |
| `tilt_deg` / `tipover_latched` | 最近有效总倾角及翻转故障锁存状态 |
| `rate_setpoint_dps[0..2]` | 目标机体角速度，顺序 R/P/Y |
| `filtered_rate_dps[0..2]` | 滤波后的陀螺反馈 |
| `rate_pid[i].p_term / i_term / d_term` | PID 各项，单位 μs |
| `correction_us[0..2]` | 混控前 R/P/Y 修正量 |
| `rc.motor_us[0..3]` | M1、M2、M3、M4 的 PWM |
| `dt_s` | 最近一次 PID 的实际时间间隔 |

现有 ANO 姿态遥测继续发送实测姿态；PID 内部量当前通过调试器观察。

## 8. 已完成的验证

开发阶段已通过 PID、闭环、遥控、输入捕获及传感器的主机验证。覆盖纠偏与目标方向、倾斜时的欧拉/机体转速转换、低油门积分、同一快照不重复积分、陈旧/无效反馈、故障后高油门不重启、时间步长异常、DWT 回绕及倾斜解锁限制。另用带 50 Hz 命令保持、执行器延迟和恒定扰动的三个简化模型验证了跟踪；模型参数是测试假设，并非辨识得到的实机参数。

Keil `Sample` 目标完成编译和链接，0 错误、0 警告。上述验证不包含实物烧录、实际控制频率测量和带桨实机整定。

## 9. 原理参考

串级外环/内环、测量微分和抗积分饱和可参考 [PX4 控制结构](https://docs.px4.io/main/en/flight_stack/controller_diagrams)；内环先于外环的整定顺序与微分反馈原理可参考 [PX4 多旋翼 PID 调参指南](https://docs.px4.io/main/en/config_mc/pid_tuning_guide_multicopter)。本项目独立实现了 C 代码与自身的 μs 输出参数，未移植 PX4 模块，也未使用其机型增益作为本机参数。
