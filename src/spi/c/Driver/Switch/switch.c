#include "switch.h"

void Switch_Init(void)
{
    GPIO_Setmode(GPIOC,
                 GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3 |
                 GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7,
                 INPUT);
}

uint8_t Switch_Read(void)
{
    return (uint8_t)(GPIO_ReadPort(GPIOC) & 0xFF);
}

uint8_t Switch_ReadPin(uint32_t GPIO_Pin)
{
    return (uint8_t)GPIO_ReadPin(GPIOC, GPIO_Pin);
}
