#include "../SPI/spi_ctrl.h"

static volatile uint8_t spiRxData;
static volatile uint8_t spiTransferDone;
static volatile uint8_t spiTransferBusy;

void SPI_CtrlInit(void)
{
    spiRxData = 0;
    spiTransferDone = 0;
    spiTransferBusy = 0;
}

void SPI_SendData(uint8_t data)
{
    if(spiTransferBusy){
        return;
    }

    spiTransferBusy = 1;
    spiTransferDone = 0;

    SPI_Transfer(SPI, data);
}

uint8_t SPI_GetReadData(void)
{
    return spiRxData;
}

uint8_t SPI_IsTransferDone(void)
{
    if(spiTransferDone){
        spiTransferDone = 0;
        return 1;
    }

    return 0;
}

void SPI_Handler(void)
{
    spiRxData = SPI_GetRxData(SPI);

    spiTransferDone = 1;
    spiTransferBusy = 0;
}
