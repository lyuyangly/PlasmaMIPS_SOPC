#include "board.h"

void delay(unsigned int t)
{
	volatile unsigned int i, j;
	for(i = 0; i < t; i++)
		for(j = 0; j < 500; j++);
}


int main(void)
{
	int num;
	*((unsigned long *)(GPIO_BASE + 8)) =0xff;
	*((unsigned long *)(GPIO_BASE + 4)) =0xff;

	while(1) {
		*((unsigned long *)(DDR_BASE + 0x10)) = 0xaa;
		num = *((unsigned long *)(DDR_BASE + 0x10));
		*((unsigned long *)(GPIO_BASE + 4)) = num;
		delay(500);
		*((unsigned long *)(DDR_BASE + 0x10)) = 0x55;
		num = *((unsigned long *)(DDR_BASE + 0x10));
		*((unsigned long *)(GPIO_BASE + 4)) = num;
		delay(500);
	}
	
	return 0;
}
