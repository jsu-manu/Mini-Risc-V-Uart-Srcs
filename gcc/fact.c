#include"uart.h"
#include"print.h"
#include"counter.h" 
#include"CRAS.h"



void send_int(int a) {
	char c; 
	// for (int i = 0; i < 4; i++) {
	// 	c = (a >> (8 * i)) & 0xff; 
	// 	uart_put(c);
	// }
	c = (char)a; 
	uart_put(c); 
	c = (char)((a >> 8) & 0xff); 
	uart_put(c);
	c = (char)((a >> 16) & 0xff); 
	uart_put(c);
	c = (char)((a >> 24) & 0xff); 
	uart_put(c);
}

int recv_int() {
	int a; 
	char c; 
	// for (int i = 0; i < 4; i++) {
	// 	c = uart_read_blocking(); 
	// 	a |= ((int)c) << (i * 8);
	// }
	c = uart_read_blocking(); 
	a = (int)c; 
	c = uart_read_blocking(); 
	a |= ((int)c) << 8;
	c = uart_read_blocking(); 
	a |= ((int)c) << 16;
	c = uart_read_blocking(); 
	a |= ((int)c) << 24;
	return a; 
}

int fact(int n) {
	if (n == 1) return n; 
	else return n + fact(n-1);
}

int main(void) {
	uart_init();
	while(1) {
		char en_RAS = uart_read_blocking(); 
		set_CRAS(en_RAS); 
		int n = recv_int(); 
		zero_counter(); 
		int tot = fact(n); 
		unsigned int cnt = read_counter(); 
		send_int(tot);
		send_int(cnt); 
		print(cnt); 
	}
}