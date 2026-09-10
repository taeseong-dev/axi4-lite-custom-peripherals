#ifndef SRC_HAL_INTERRUPT_H_
#define SRC_HAL_INTERRUPT_H_

#include "xparameters.h"
#include "xintc.h"
#include "xil_exception.h"
#include "../../common/common.h"
#include "../../Driver/FND/fnd.h"
#include "../../Driver/SPI/spi_ctrl.h"

#define INTC_DEV_ID      XPAR_INTC_0_DEVICE_ID
#define TIMER0_INTR_ID   XPAR_INTC_0_TMR_0_VEC_ID
#define SPI_INTR_ID      XPAR_INTC_0_AXI_SPI_0_VEC_ID

void TMR0_ISR(void *CallbackRef);
void SPI_ISR(void *CallbackRef);
int SetupInterruptSystem(void);

#endif /* SRC_HAL_INTERRUPT_H_ */
