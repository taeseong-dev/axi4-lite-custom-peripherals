#ifndef SRC_HAL_INTERRUPT_H_
#define SRC_HAL_INTERRUPT_H_

#include "xparameters.h"
#include "xintc.h"
#include "xil_exception.h"
#include "../../common/common.h"
#include "../../Driver/FND/fnd.h"
#include "../../Driver/I2C/i2c_ctrl.h"

#define INTC_DEV_ID 	XPAR_INTC_0_DEVICE_ID
#define TIMER0_INTR_ID 	XPAR_INTC_0_TMR_0_VEC_ID
#define I2C_INTR_ID		XPAR_INTC_0_AXI_I2C_0_VEC_ID

void TMR0_ISR(void *CallbackRef);
void I2C_ISR(void *CallbackRef);
int SetupInterruptSystem();


#endif /* SRC_COMMON_INTERRUPT_H_ */
