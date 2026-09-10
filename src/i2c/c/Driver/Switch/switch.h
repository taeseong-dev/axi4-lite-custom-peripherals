#ifndef SRC_DRIVER_SWITCH_SWITCH_H_
#define SRC_DRIVER_SWITCH_SWITCH_H_

#include <stdint.h>
#include "../../HAL/GPIO/GPIO.h"

void Switch_Init();
uint8_t Switch_Read();
uint8_t Switch_ReadPin(uint32_t GPIO_Pin);

#endif /* SRC_DRIVER_SWITCH_SWITCH_H_ */
