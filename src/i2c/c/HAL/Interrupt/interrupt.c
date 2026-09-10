#include "interrupt.h"

XIntc IntrController;

// 1KHz -> 1msec interrupt service routine
void TMR0_ISR(void *CallbackRef)
{
    (void)CallbackRef;
    millis_inc();
    FND_DispDigit();
}

void I2C_ISR(void *CallbackRef)
{
    (void)CallbackRef;
    I2C_Handler();
}

int SetupInterruptSystem(void)
{
    int status;

    // 1. Interrupt Controller 초기화
    status = XIntc_Initialize(&IntrController, INTC_DEV_ID);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 2. ISR 연결
    status = XIntc_Connect(&IntrController, TIMER0_INTR_ID, (XInterruptHandler)TMR0_ISR, (void *)0);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    status = XIntc_Connect(&IntrController, I2C_INTR_ID, (XInterruptHandler)I2C_ISR, (void *)0);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 3. Interrupt Controller 시작 (Hardware Mode)
    status = XIntc_Start(&IntrController, XIN_REAL_MODE);
    if(status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // 4. Interrupt Channel 활성화
    XIntc_Enable(&IntrController, TIMER0_INTR_ID);
    XIntc_Enable(&IntrController, I2C_INTR_ID);

    // 5. MicroBlaze Exception 초기화 및 활성화
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
            (Xil_ExceptionHandler)XIntc_InterruptHandler,
            &IntrController);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
