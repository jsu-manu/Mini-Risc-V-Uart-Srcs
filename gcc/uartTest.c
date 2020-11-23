#include"uart.h" 
// #include"print.h" 
#include"utils.h"

int main(void) {
	// uart_init(); 

	char h[] = "Hello, world!\r\n"; 
	// // int strlen = 13; 
	uart_print(h);
	
	// char numchar[12];
	// int num = 32; 

	// itoa(num, numchar);
	// uart_print(numchar);

	// char c; 
	// while(1) {
	// 	c = uart_read_blocking();
	// 	// uart_write_blocking(c);
	// 	uart_put(c);
	// }
	// return 0;
}
