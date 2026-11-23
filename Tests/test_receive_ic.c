/* gcc -std=c99 -Wall -Wextra -Werror -pedantic -ITests/rc_stubs -IMyLib
 *   Tests/test_receive_ic.c MyLib/Receive_IC.c MyLib/RC_Control.c
 *   -o Objects/test_receive_ic.exe
 * 没有提供任何 BLDC 桩函数：捕获中断若重新直接控制电机，将无法链接。
 */
#include "main.h"
#include "Receive_IC.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

TIM_TypeDef rc_test_tim2, rc_test_tim4;
uint32_t rc_test_primask;
extern TIM_HandleTypeDef htim2, htim4;
static uint32_t s_tick;
static unsigned s_started;

void HAL_GPIO_Init(unsigned port, GPIO_InitTypeDef *gpio)
{
    assert(port <= 1u && gpio->Mode == GPIO_MODE_AF_PP);
}
int HAL_TIM_Base_Init(TIM_HandleTypeDef *timer)
{
    assert(timer->Init.Prescaler == 83u);
    assert(timer->Init.Period == (timer->Instance == TIM2 ? UINT32_MAX : 0xFFFFu));
    return HAL_OK;
}
int HAL_TIM_IC_Init(TIM_HandleTypeDef *timer) { (void)timer; return HAL_OK; }
int HAL_TIM_IC_ConfigChannel(TIM_HandleTypeDef *timer, TIM_IC_InitTypeDef *config, uint32_t channel)
{
    assert(config->ICPolarity == TIM_ICPOLARITY_RISING);
    assert(config->ICSelection == TIM_ICSELECTION_DIRECTTI);
    timer->Instance->polarity[channel / 4u] = config->ICPolarity;
    return HAL_OK;
}
int HAL_TIM_IC_Start_IT(TIM_HandleTypeDef *timer, uint32_t channel)
{
    (void)timer; (void)channel; ++s_started; return HAL_OK;
}
void HAL_NVIC_SetPriority(unsigned irq, unsigned priority, unsigned subpriority)
{
    assert((irq == TIM2_IRQn || irq == TIM4_IRQn) && priority == 2u && subpriority == 0u);
}
void HAL_NVIC_EnableIRQ(unsigned irq) { assert(irq == TIM2_IRQn || irq == TIM4_IRQn); }
uint32_t HAL_TIM_ReadCapturedValue(TIM_HandleTypeDef *timer, uint32_t channel)
{
    return timer->Instance->captured[channel / 4u];
}
uint32_t HAL_GetTick(void) { return s_tick; }
void Error_Handler(void) { abort(); }

static void Reset(void)
{
    memset(&rc_test_tim2, 0, sizeof(rc_test_tim2));
    memset(&rc_test_tim4, 0, sizeof(rc_test_tim4));
    s_started = 0u;
    rc_test_primask = 0u;
    IC_Init();
    assert(s_started == 4u);
}

static void Pulse(unsigned idx, uint32_t rising, uint32_t width,
                  uint32_t rising_ms, uint32_t falling_ms)
{
    TIM_HandleTypeDef *timer = idx < 3u ? &htim2 : &htim4;
    unsigned local_channel = idx < 3u ? idx : 1u;
    uint32_t mask = idx < 3u ? UINT32_MAX : 0xFFFFu;
    timer->Channel = 1u << local_channel;
    assert(timer->Instance->polarity[local_channel] == TIM_ICPOLARITY_RISING);
    timer->Instance->captured[local_channel] = rising & mask;
    s_tick = rising_ms;
    HAL_TIM_IC_CaptureCallback(timer);
    assert(timer->Instance->polarity[local_channel] == TIM_ICPOLARITY_FALLING);
    timer->Instance->captured[local_channel] = (rising + width) & mask;
    s_tick = falling_ms;
    HAL_TIM_IC_CaptureCallback(timer);
    assert(timer->Instance->polarity[local_channel] == TIM_ICPOLARITY_RISING);
    assert(s_started == 4u); /* 不能在边沿捕获时反复停启定时器。 */
}

static void TestChannelsAndWrap(void)
{
    RC_Input_t input;
    RC_Command_t command;
    unsigned i;
    Reset();
    IC_GetSnapshot(&input);
    assert(input.valid_mask == 0u);
    assert(!RC_Decode(&input, 0u, &command));
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        Pulse(i, 10000u + i * 2000u, 1500u, 100u, 102u);
    }
    IC_GetSnapshot(&input);
    assert(input.valid_mask == RC_ALL_CHANNELS_MASK);
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        assert(input.pulse_us[i] == 1500u && input.updated_ms[i] == 102u);
    }
    assert(RC_Decode(&input, 102u, &command));
    assert(command.throttle == 0.0f && command.roll == 0.0f && command.pitch == 0.0f);
    assert(rc_test_primask == 0u);
    rc_test_primask = 1u;
    IC_GetSnapshot(&input);
    assert(rc_test_primask == 1u);
    IC_GetSnapshot(NULL);
    assert(rc_test_primask == 1u);

    Pulse(0u, UINT32_MAX - 500u, 1500u, 120u, 122u);
    Pulse(3u, 65000u, 1500u, 120u, 122u);
    IC_GetSnapshot(&input);
    assert(input.pulse_us[0] == 1500u && input.pulse_us[3] == 1500u);
    assert(input.valid_mask == RC_ALL_CHANNELS_MASK);
    Pulse(3u, 65000u, 1500u, UINT32_MAX, 1u);
    IC_GetSnapshot(&input);
    assert(input.updated_ms[3] == 1u && (input.valid_mask & 8u));
}

static void TestInvalidAndRecovery(void)
{
    RC_Input_t input;
    unsigned i;
    Reset();
    for (i = 0u; i < RC_CHANNEL_COUNT; ++i) {
        Pulse(i, 1000u, 1500u, 100u, 102u);
        Pulse(i, 10000u, 899u, 120u, 121u);
        IC_GetSnapshot(&input);
        assert(!(input.valid_mask & (1u << i)));
        Pulse(i, 20000u, 2101u, 140u, 143u);
        IC_GetSnapshot(&input);
        assert(!(input.valid_mask & (1u << i)));
        Pulse(i, 30000u, 1500u, 160u, 162u);
        IC_GetSnapshot(&input);
        assert(input.valid_mask & (1u << i));
    }
    Pulse(0u, 1000u, 65536u + 1500u, 200u, 267u);
    IC_GetSnapshot(&input);
    assert(!(input.valid_mask & 1u) && input.pulse_us[0] == 0u);
    Pulse(3u, 1000u, 65536u + 1500u, 200u, 267u);
    IC_GetSnapshot(&input);
    assert(!(input.valid_mask & 8u)); /* TIM4 看起来是 1500us，实际高电平过长。 */
    Pulse(3u, 1000u, 1500u, 300u, 302u);
    IC_GetSnapshot(&input);
    assert(input.valid_mask & 8u);

    htim4.Channel = HAL_TIM_ACTIVE_CHANNEL_2;
    rc_test_tim4.flags = TIM_FLAG_CC2OF;
    HAL_TIM_IC_CaptureCallback(&htim4);
    IC_GetSnapshot(&input);
    assert(!(input.valid_mask & 8u) && rc_test_tim4.flags == 0u);
    Pulse(3u, 1000u, 1500u, 320u, 322u);
    IC_GetSnapshot(&input);
    assert(input.valid_mask & 8u);
}

int main(void)
{
    TestChannelsAndWrap();
    TestInvalidAndRecovery();
    puts("PASS: four capture channels, atomic snapshots, TIM2/TIM4 wrap, long/invalid pulses,");
    puts("      overcapture recovery, millisecond wrap and no motor writes in capture ISR.");
    return 0;
}
