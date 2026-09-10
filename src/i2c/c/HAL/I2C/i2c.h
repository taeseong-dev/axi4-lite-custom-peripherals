#ifndef SRC_HAL_I2C_H_
#define SRC_HAL_I2C_H_

#include <stdint.h>
#include "xparameters.h"

#define I2C_BASE_ADDR XPAR_AXI_I2C_0_S00_AXI_BASEADDR



#define I2C_CR_CLK_DIV_SHIFT 	8
#define I2C_CR_CLK_DIV_MASK     (0xFFFFU << I2C_CR_CLK_DIV_SHIFT)

#define I2C_CR_START    	(1U << 0)
#define I2C_CR_WRITE    	(1U << 1)
#define I2C_CR_READ    		(1U << 2)
#define I2C_CR_STOP   		(1U << 3)
#define I2C_CR_ACK_IN    	(1U << 4)
#define I2C_CR_INTR_EN    	(1U << 5)

#define I2C_SR_BUSY    		(1U << 0)
#define I2C_SR_ACK_OUT    	(1U << 1)

typedef struct {
	volatile uint32_t SR;
	volatile uint32_t TXDR;
	volatile uint32_t RXDR;
	volatile uint32_t CR;
} I2C_Typedef_t;

#define I2C ((I2C_Typedef_t *) (I2C_BASE_ADDR))

void I2C_Init(I2C_Typedef_t *I2Cx);
void I2C_Start(I2C_Typedef_t *I2Cx);
void I2C_Write(I2C_Typedef_t *I2Cx, uint8_t data);
void I2C_Read(I2C_Typedef_t *I2Cx);
void I2C_Stop(I2C_Typedef_t *I2Cx);
uint8_t I2C_GetRxData(I2C_Typedef_t *I2Cx);
uint8_t I2C_GetAck(I2C_Typedef_t *I2Cx);
void I2C_SetAck(I2C_Typedef_t *I2Cx, uint8_t ack);
void I2C_SetIntr(I2C_Typedef_t *I2Cx, uint8_t enable);
void I2C_SetClkDiv(I2C_Typedef_t *I2Cx, uint16_t clk_div);

#endif /* SRC_DRIVER_I2C_I2C_H_ */
