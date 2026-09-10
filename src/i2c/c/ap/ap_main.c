#include "ap_main.h"
#include "../common/common.h"
#include "../HAL/TIMER/TMR.h"
#include "../HAL/Interrupt/interrupt.h"
#include "../Driver/Button/button.h"
#include "../Driver/FND/fnd.h"
#include "../HAL/GPIO/GPIO.h"
#include "../Driver/Switch/switch.h"
#include "../HAL/I2C/i2c.h"
#include "../Driver/I2C/i2c_ctrl.h"

hBtn_t hbtnWrite;
hBtn_t hbtnRead;

uint8_t swData = 0;
uint8_t i2cReadData = 0;

void ap_init()
{
	Button_Init(&hbtnWrite,    GPIOA, GPIO_PIN_4);
	Button_Init(&hbtnRead,     GPIOA, GPIO_PIN_5);

	Switch_Init();
	FND_Init();
	I2C_Init(I2C);
	I2C_CtrlInit();
	SetupInterruptSystem();

	//I2C interrupt
	I2C_SetIntr(I2C, 1);

	// 1ms interrupt
	TMR_SetPSC(TMR0, 100-1);
	TMR_SetARR(TMR0, 1000-1);
	TMR_StartIntr(TMR0);
	TMR_StartTimer(TMR0);


}

void ap_execute()
{
    // I2C Write
    if(Button_GetState(&hbtnWrite) == ACT_RELEASED){
        swData = Switch_Read();
        I2C_SendData(0x12, swData);
    }

    // I2C Read
    if(Button_GetState(&hbtnRead) == ACT_RELEASED){
        I2C_ReadData(0x12);
    }

    // I2C Read ¿Ï·á
    if(I2C_IsReadDone()){
        i2cReadData = I2C_GetReadData();
    }

    // FND Display
    FND_SetNum(i2cReadData);
}
