#ifndef SRC_DRIVER_I2C_CTRL_H_
#define SRC_DRIVER_I2C_CTRL_H_

#include <stdint.h>
#include "../../HAL/I2C/i2c.h"

void I2C_CtrlInit(void);
void I2C_SendData(uint8_t slave_addr, uint8_t data);
void I2C_ReadData(uint8_t slave_addr);
uint8_t I2C_GetReadData(void);
uint8_t I2C_IsReadDone(void);
void I2C_Handler(void);

#endif /* SRC_DRIVER_I2C_CTRL_H_ */
