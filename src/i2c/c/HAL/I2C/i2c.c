#include "i2c.h"

void I2C_Init(I2C_Typedef_t *I2Cx)
{
    I2Cx->TXDR = 0;
    I2Cx->CR = 0;

    I2C_SetClkDiv(I2Cx, 250);
}

void I2C_Start(I2C_Typedef_t *I2Cx)
{
    I2Cx->CR |= I2C_CR_START;
}

void I2C_Write(I2C_Typedef_t *I2Cx, uint8_t data)
{
    I2Cx->TXDR = data;
    I2Cx->CR |= I2C_CR_WRITE;
}

void I2C_Read(I2C_Typedef_t *I2Cx)
{
    I2Cx->CR |= I2C_CR_READ;
}

void I2C_Stop(I2C_Typedef_t *I2Cx)
{
    I2Cx->CR |= I2C_CR_STOP;
}

uint8_t I2C_GetRxData(I2C_Typedef_t *I2Cx)
{
    return (uint8_t)(I2Cx->RXDR & 0xFF);
}

uint8_t I2C_GetAck(I2C_Typedef_t *I2Cx)
{
    return (I2Cx->SR & I2C_SR_ACK_OUT) ? 1 : 0;
}

void I2C_SetAck(I2C_Typedef_t *I2Cx, uint8_t ack)
{
    if(ack){
        I2Cx->CR |= I2C_CR_ACK_IN;
    }
    else{
        I2Cx->CR &= ~I2C_CR_ACK_IN;
    }
}

void I2C_SetIntr(I2C_Typedef_t *I2Cx, uint8_t enable)
{
    if(enable){
        I2Cx->CR |= I2C_CR_INTR_EN;
    }
    else{
        I2Cx->CR &= ~I2C_CR_INTR_EN;
    }
}

void I2C_SetClkDiv(I2C_Typedef_t *I2Cx, uint16_t clk_div)
{
    I2Cx->CR &= ~I2C_CR_CLK_DIV_MASK;
    I2Cx->CR |= ((uint32_t)clk_div << I2C_CR_CLK_DIV_SHIFT);
}
