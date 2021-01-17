#include "uart.h"

int main(void)
{
	uart_init();

	char h[] = "1234567890abcdefghijk\r\n";
	uart_print(h);

	char numchar[12];
	int num = 32;

	itoa(num, numchar);
	uart_print(numchar);

	char c;
	while (1)
	{
		c = uart_read_blocking();
		uart_put(c);
	}
	return 0;
}
