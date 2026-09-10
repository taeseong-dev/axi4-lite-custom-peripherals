#ifndef SRC_DRIVER_SPI_CTRL_H_
#define SRC_DRIVER_SPI_CTRL_H_

#include <stdint.h>
#include "../../HAL/SPI/spi.h"

void SPI_CtrlInit(void);
void SPI_SendData(uint8_t data);

uint8_t SPI_GetReadData(void);
uint8_t SPI_IsTransferDone(void);

void SPI_Handler(void);

#endif /* SRC_DRIVER_SPI_CTRL_H_ */
