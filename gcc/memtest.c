#include"uart.h"

int main(void) {
	uart_init(); 
	char * tst = "Hello, world!\n"; 
	uart_print(tst);
	
}
