#include "../I2C/i2c_ctrl.h"

typedef enum {
    I2C_CTRL_IDLE,
    I2C_CTRL_START,
    I2C_CTRL_WRITE_ADDR_RW,
    I2C_CTRL_WRITE_DATA,
    I2C_CTRL_READ_DATA,
    I2C_CTRL_STOP
} I2C_CtrlState_t;

static I2C_CtrlState_t i2cCtrlState = I2C_CTRL_IDLE;

static uint8_t i2cRw = 0;
static uint8_t i2cSlaveAddr = 0;
static uint8_t i2cTxData = 0;
static uint8_t i2cRxData = 0;
static volatile uint8_t i2cReadDone = 0;

void I2C_CtrlInit(void)
{
    i2cCtrlState = I2C_CTRL_IDLE;
    i2cRw = 0;
    i2cSlaveAddr = 0;
    i2cTxData = 0;
    i2cRxData = 0;
    i2cReadDone = 0;
}

void I2C_SendData(uint8_t slave_addr, uint8_t data)
{
    if(i2cCtrlState != I2C_CTRL_IDLE){
        return;
    }

    i2cSlaveAddr = slave_addr;
    i2cTxData = data;
    i2cRw = 0;

    i2cCtrlState = I2C_CTRL_START;
    I2C_Start(I2C);
}

void I2C_ReadData(uint8_t slave_addr)
{
    if(i2cCtrlState != I2C_CTRL_IDLE){
        return;
    }

    i2cSlaveAddr = slave_addr;
    i2cRw = 1;

    i2cCtrlState = I2C_CTRL_START;
    I2C_Start(I2C);
}

uint8_t I2C_GetReadData(void)
{
    return i2cRxData;
}

uint8_t I2C_IsReadDone(void)
{
    if(i2cReadDone){
        i2cReadDone = 0;
        return 1;
    }

    return 0;
}

void I2C_Handler(void)
{
    switch(i2cCtrlState)
    {

    case I2C_CTRL_IDLE:
        break;

    case I2C_CTRL_START:
        i2cCtrlState = I2C_CTRL_WRITE_ADDR_RW;
        I2C_Write(I2C, (i2cSlaveAddr << 1) | i2cRw);
        break;

    case I2C_CTRL_WRITE_ADDR_RW:
        if(I2C_GetAck(I2C)){
            i2cCtrlState = I2C_CTRL_STOP;
            I2C_Stop(I2C);
            break;
        }

        if(i2cRw == 0){
            i2cCtrlState = I2C_CTRL_WRITE_DATA;
            I2C_Write(I2C, i2cTxData);
        }
        else{
            I2C_SetAck(I2C, 1);
            i2cCtrlState = I2C_CTRL_READ_DATA;
            I2C_Read(I2C);
        }
        break;

    case I2C_CTRL_WRITE_DATA:
        i2cCtrlState = I2C_CTRL_STOP;
        I2C_Stop(I2C);
        break;

    case I2C_CTRL_READ_DATA:
        i2cRxData = I2C_GetRxData(I2C);
        i2cReadDone = 1;

        i2cCtrlState = I2C_CTRL_STOP;
        I2C_Stop(I2C);
        break;

    case I2C_CTRL_STOP:
        i2cCtrlState = I2C_CTRL_IDLE;
        break;

    default:
        i2cCtrlState = I2C_CTRL_IDLE;
        break;

    }
}
