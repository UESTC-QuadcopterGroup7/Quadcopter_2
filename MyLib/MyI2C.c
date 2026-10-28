#include "main.h"
#include "Delay.h"
#include "GPIO_Set.h"

#define SCL_Pin GPIO_PIN_8
#define SDA_Pin GPIO_PIN_9
#define SCL_Port GPIOB
#define SDA_Port GPIOB

/*
 * 半周期延时。原来是 10us（≈50kHz），配合 Timer_Delay_us 的调用开销，
 * 整条总线只有十几 kHz。GY-86 上的 MPU6050/HMC5883L 都支持 400kHz，
 * 上拉电阻是模块自带的 4.7k，2us 半周期（≈150~200kHz）是安全的。
 */
#define I2C_DELAY_US   2u

void MyI2C_W_SCL(uint8_t BitValue) {
	HAL_GPIO_WritePin(SCL_Port, SCL_Pin, (GPIO_PinState)BitValue);
	Timer_Delay_us(I2C_DELAY_US);
}

void MyI2C_W_SDA(uint8_t BitValue) {
	HAL_GPIO_WritePin(SDA_Port, SDA_Pin, (GPIO_PinState)BitValue);
	Timer_Delay_us(I2C_DELAY_US);
}

uint8_t MyI2C_R_SDA(void) {
	uint8_t BitValue;
	BitValue = HAL_GPIO_ReadPin(SDA_Port, SDA_Pin);
	Timer_Delay_us(I2C_DELAY_US);
	return BitValue;
}

void MyI2C_Init(void) {
	__HAL_RCC_GPIOB_CLK_ENABLE();
	GPIO_CFG(SCL_Port /*SDA_Port*/ , SCL_Pin | SDA_Pin,  \
	GPIO_MODE_OUTPUT_OD, GPIO_SPEED_FREQ_VERY_HIGH, GPIO_NOPULL);
	HAL_GPIO_WritePin(SDA_Port, SDA_Pin | SCL_Pin, GPIO_PIN_SET);
}

void MyI2C_Start(void) {
	MyI2C_W_SDA(1);
	MyI2C_W_SCL(1);
	MyI2C_W_SDA(0);
	MyI2C_W_SCL(0);
}

void MyI2C_Stop(void) {
	MyI2C_W_SDA(0);
	MyI2C_W_SCL(1);
	MyI2C_W_SDA(1);
}

void MyI2C_SendByte(uint8_t Byte) {
	for(uint8_t i = 0; i < 8; i++) {
		MyI2C_W_SDA(Byte & ((1 << 7) >> i));
		MyI2C_W_SCL(1);
		MyI2C_W_SCL(0);
	}
}

uint8_t MyI2C_ReceiveByte(void) {
	uint8_t ByteRec = 0x0;
	MyI2C_W_SDA(1);
	for(uint8_t i = 0; i < 8; i++) {
		MyI2C_W_SCL(1);
		if(MyI2C_R_SDA() == 1) {
			ByteRec |= ((1 << 7) >> i);
		}
		MyI2C_W_SCL(0);
	}
	return ByteRec;
}

void MyI2C_SendAck(uint8_t AckBit)
{	
	MyI2C_W_SDA(AckBit);
	MyI2C_W_SCL(1);
	MyI2C_W_SCL(0);
}

uint8_t MyI2C_ReceiveAck(void)
{
	uint8_t AckBit;
	MyI2C_W_SDA(1);
	MyI2C_W_SCL(1);
	AckBit=MyI2C_R_SDA();
	MyI2C_W_SCL(0);
	return AckBit;
}
