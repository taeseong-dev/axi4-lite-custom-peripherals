#include "common.h"

volatile uint32_t millis_tick=0;

uint32_t millis()
{
	return millis_tick;
}

void millis_inc()
{
	millis_tick++;
}

void delay_ms(uint32_t msec)
{
    uint32_t prevMillis = millis();

    while(millis() - prevMillis < msec);
}
