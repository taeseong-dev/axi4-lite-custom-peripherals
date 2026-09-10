#include "fnd.h"

uint8_t fndDpData = 0;
uint16_t fndNumData = 0;

void FND_Init()
{
	//GPIO 설정, GPIOA 0,1,2,3 COM 연결
	GPIO_Setmode(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OUTPUT);
	//GPIO 설정, GPIOB seg abcdefg, dp
	GPIO_Setmode(FND_FONT_PORT, SEG_PIN_A|SEG_PIN_B|SEG_PIN_C|SEG_PIN_D|SEG_PIN_E|SEG_PIN_F|SEG_PIN_G|SEG_PIN_DP, OUTPUT);

}

void FND_SetComPort(GPIO_Typedef_t *FND_Port, uint32_t Seg_Pin, int OnOff)
{

	GPIO_WritePin(FND_Port, Seg_Pin, OnOff);
}

void FND_SetDP(uint8_t digit, uint8_t on_off)
{
	if (digit == FND_DIGIT_1){
		if(!on_off) fndDpData |= 1<<0;
		else fndDpData &= ~(1<<0);
	}
	else if (digit == FND_DIGIT_10){
		if(!on_off) fndDpData |= 1<<1;
		else fndDpData &= ~(1<<1);
	}
	else if (digit == FND_DIGIT_100){
		if(!on_off) fndDpData |= 1<<2;
		else fndDpData &= ~(1<<2);
	}
	else if (digit == FND_DIGIT_1000){
		if(!on_off) fndDpData |= 1<<3;
		else fndDpData &= ~(1<<3);
	}
}

void FND_DispDP(uint8_t digit)
{
	 if(fndDpData & digit) {
		 GPIO_WritePin(FND_FONT_PORT, SEG_PIN_DP, RESET);
	 }
	 else {
		 GPIO_WritePin(FND_FONT_PORT, SEG_PIN_DP, SET);
	 }
}



void FND_DispDigit()
{

	static uint8_t FndDigState = 0;
	FndDigState = (FndDigState + 1) % 4;

	switch(FndDigState)
	{
	case 0 : FND_DispDigit_1();
			 FND_DispDP(FND_DIGIT_1);
			 break;
	case 1 : FND_DispDigit_10();
			 FND_DispDP(FND_DIGIT_10);
			 break;
	case 2 : FND_DispDigit_100();
			 FND_DispDP(FND_DIGIT_100);
			 break;
	case 3 : FND_DispDigit_1000();
			 FND_DispDP(FND_DIGIT_1000);
			 break;

	default : FND_DispDigit_1();   break;
	}

}

void FND_DispDigit_1()
{
	uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};

	uint8_t digitData1 =  fndNumData % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData1]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1, ON);

}
void FND_DispDigit_10()
{
	uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};
	uint8_t digitData10 =  fndNumData / 10 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData10]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_2, ON);

}
void FND_DispDigit_100()
{
	uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};
	uint8_t digitData100 =  fndNumData / 100 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData100]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_3, ON);

}
void FND_DispDigit_1000()
{
	uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};
	uint8_t digitData1000 =  fndNumData / 1000 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData1000]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_4, ON);

}

void FND_SetNum(uint16_t num)
{
	fndNumData = num;

}


void FND_DisAllpOn()
{
	GPIO_WritePort(FND_FONT_PORT, 0x00);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, ON);


}
void FND_DispAllOff()
{
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, 0xff);
}

//void FND_DispDigit_DP(uint8_t digit, uint8_t on_off)
//{
//	FND_DispAllOff();
//	GPIO_WritePort(FND_FONT_PORT, on_off);
//	FND_SetComPort(FND_COM_PORT, digit, ON);
//}
//
//void FND_DispDigit_1_DP(uint8_t on_off)
//{
//	FND_DispDigit_DP(FND_DIGIT_1, on_off);
//}
//void FND_DispDigit_10_DP(uint8_t on_off)
//{
//	FND_DispDigit_DP(FND_DIGIT_10, on_off);
//
//}
//
//void FND_DispDigit_100_DP(uint8_t on_off)
//{
//	FND_DispDigit_DP(FND_DIGIT_100, on_off);
//
//}
//
//void FND_DispDigit_1000_DP(uint8_t on_off)
//{
//	FND_DispDigit_DP(FND_DIGIT_1000, on_off);
//
//}
