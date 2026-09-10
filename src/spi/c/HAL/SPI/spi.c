#include "../SPI/spi.h"

void SPI_Init(SPI_Typedef_t *SPIx)
{
    SPIx->TXDR = 0;
    SPIx->CR = 0;

    SPI_SetClkDiv(SPIx, 49);
}

void SPI_Transfer(SPI_Typedef_t *SPIx, uint8_t data)
{
    SPIx->TXDR = data;
    SPIx->CR |= SPI_CR_START;
}

uint8_t SPI_GetRxData(SPI_Typedef_t *SPIx)
{
    return (uint8_t)(SPIx->RXDR & 0xFF);
}

uint8_t SPI_GetBusy(SPI_Typedef_t *SPIx)
{
    return (SPIx->SR & SPI_SR_BUSY) ? 1 : 0;
}

void SPI_SetMode(SPI_Typedef_t *SPIx, uint8_t cpol, uint8_t cpha)
{
    uint32_t cr = SPIx->CR;

    cr &= ~(SPI_CR_CPOL | SPI_CR_CPHA);

    if(cpol){
        cr |= SPI_CR_CPOL;
    }

    if(cpha){
        cr |= SPI_CR_CPHA;
    }

    SPIx->CR = cr;
}

void SPI_SetIntr(SPI_Typedef_t *SPIx, uint8_t enable)
{
    if(enable){
        SPIx->CR |= SPI_CR_INTR_EN;
    }
    else{
        SPIx->CR &= ~SPI_CR_INTR_EN;
    }
}

void SPI_SetClkDiv(SPI_Typedef_t *SPIx, uint16_t clk_div)
{
    SPIx->CR &= ~SPI_CR_CLK_DIV_MASK;
    SPIx->CR |= ((uint32_t)clk_div << SPI_CR_CLK_DIV_SHIFT);
}
