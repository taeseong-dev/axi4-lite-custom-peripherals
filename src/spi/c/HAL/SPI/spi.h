#ifndef SRC_HAL_SPI_H_
#define SRC_HAL_SPI_H_

#include <stdint.h>
#include "xparameters.h"

#define SPI_BASE_ADDR XPAR_AXI_SPI_0_S00_AXI_BASEADDR

#define SPI_CR_CLK_DIV_SHIFT    8
#define SPI_CR_CLK_DIV_MASK     (0xFFFFU << SPI_CR_CLK_DIV_SHIFT)

#define SPI_CR_START            (1U << 0)
#define SPI_CR_CPOL             (1U << 1)
#define SPI_CR_CPHA             (1U << 2)
#define SPI_CR_INTR_EN          (1U << 3)

#define SPI_SR_BUSY             (1U << 0)

typedef struct {
    volatile uint32_t SR;
    volatile uint32_t TXDR;
    volatile uint32_t RXDR;
    volatile uint32_t CR;
} SPI_Typedef_t;

#define SPI ((SPI_Typedef_t *) (SPI_BASE_ADDR))

void SPI_Init(SPI_Typedef_t *SPIx);
void SPI_Transfer(SPI_Typedef_t *SPIx, uint8_t data);
uint8_t SPI_GetRxData(SPI_Typedef_t *SPIx);
uint8_t SPI_GetBusy(SPI_Typedef_t *SPIx);
void SPI_SetMode(SPI_Typedef_t *SPIx, uint8_t cpol, uint8_t cpha);
void SPI_SetIntr(SPI_Typedef_t *SPIx, uint8_t enable);
void SPI_SetClkDiv(SPI_Typedef_t *SPIx, uint16_t clk_div);

#endif /* SRC_HAL_SPI_H_ */
