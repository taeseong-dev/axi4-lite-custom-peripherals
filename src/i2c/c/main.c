#include "ap/ap_main.h"
#include "xparameters.h"

// main 함수 : system 초기화 및 실행
int main() {

	ap_init();

	while(1)
	{
		ap_execute();
	}
	return 0;

}

