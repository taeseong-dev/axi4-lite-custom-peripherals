#include "interrupt.h"

XIntc IntrController;

// 1KHz -> 1msec interrupt service routine
void TMR0_ISR(void *CallbackRef)
{
    (void)CallbackRef;
    millis_inc();
    FND_DispDigit();
}

void SPI_ISR(void *CallbackRef)
{
    (void)CallbackRef;
    SPI_Handler();
}

int SetupInterruptSystem(void)
{
    int status;

    // 1. Initialize interrupt controller
    status = XIntc_Initialize(&IntrController, INTC_DEV_ID);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 2. Connect interrupt handlers
    status = XIntc_Connect(&IntrController, TIMER0_INTR_ID, (XInterruptHandler)TMR0_ISR, (void *)0);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    status = XIntc_Connect(&IntrController, SPI_INTR_ID, (XInterruptHandler)SPI_ISR, (void *)0);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 3. Start Interrupt Controller (Hardware Mode)
    status = XIntc_Start(&IntrController, XIN_REAL_MODE);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 4. Enable interrupt channels
    XIntc_Enable(&IntrController, TIMER0_INTR_ID);
    XIntc_Enable(&IntrController, SPI_INTR_ID);

    // 5. Initialize and enable MicroBlaze exceptions
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
            (Xil_ExceptionHandler)XIntc_InterruptHandler,
            &IntrController);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
