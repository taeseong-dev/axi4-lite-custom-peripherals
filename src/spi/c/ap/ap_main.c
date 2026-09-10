#include "ap_main.h"
#include "../common/common.h"
#include "../HAL/TIMER/TMR.h"
#include "../HAL/Interrupt/interrupt.h"
#include "../Driver/Button/button.h"
#include "../Driver/FND/fnd.h"
#include "../HAL/GPIO/GPIO.h"
#include "../Driver/Switch/switch.h"
#include "../HAL/SPI/spi.h"
#include "../Driver/SPI/spi_ctrl.h"

hBtn_t hbtnTransfer;

uint8_t swData = 0;
uint8_t spiReadData = 0;

void ap_init()
{
    Button_Init(&hbtnTransfer, GPIOA, GPIO_PIN_4);

    Switch_Init();
    FND_Init();
    SPI_Init(SPI);
    SPI_CtrlInit();
    SPI_SetMode(SPI, 0, 0);     // Mode 0
    SetupInterruptSystem();

    // SPI interrupt
    SPI_SetIntr(SPI, 1);

    // 1ms interrupt
    TMR_SetPSC(TMR0, 100-1);
    TMR_SetARR(TMR0, 1000-1);
    TMR_StartIntr(TMR0);
    TMR_StartTimer(TMR0);
}

void ap_execute()
{
    // SPI Transfer
    if(Button_GetState(&hbtnTransfer) == ACT_RELEASED){
        swData = Switch_Read();
        SPI_SendData(swData);
    }

    // SPI Transfer Complete
    if(SPI_IsTransferDone()){
        spiReadData = SPI_GetReadData();
    }

    // FND Display
    FND_SetNum(spiReadData);
}
