#include"print.h" 
#include"uart.h" 
// #include"malloc.h"
#include"counter.h" 
#include"CRAS.h"

void swap(int *a, int *b) {
	int t = *a; 
	*a = *b; 
	*b = t; 
}

int partition(int arr[], int low, int high) {
	int pivot = arr[high]; 
	int i = (low - 1); 

	for (int j = low; j <= high - 1; j++) {
		if (arr[j] < pivot) {
			i++; 
			swap(&arr[i], &arr[j]); 
		}
	}
	swap(&arr[i+1], &arr[high]); 
	return (i + 1); 
}

void quicksort(int arr[], int low, int high) {
	if (low < high) {
		int pi = partition(arr, low, high); 
		quicksort(arr, low, pi - 1); 
		quicksort(arr, pi + 1, high);
	}
}

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

char tx_fifo_empty() {
	char c = uart_poll(); 
	c = c & 0x20; 
	if (c != 0) return 1;
	else return 0;
}


int main(void) {
	uart_init();
	while(1) {
		char en_RAS = uart_read_blocking(); 
		set_CRAS(en_RAS);
		print(en_RAS);
		int len = recv_int(); 
		int arr[len]; 
		// int * arr = malloc(len * sizeof(int));
		for (int i = 0; i < len; i++) {
			arr[i] = recv_int();
			// arr[i] = len - i; 
		}
		// for (int i = 0; i < len; i++) {
		// 	arr[i] = len - i; 
		// }
		zero_counter(); 
		quicksort(arr, 0, len-1);
		unsigned int cnt = read_counter(); 
		for (int i = 0; i < len; i++) {
			while(!tx_fifo_empty());
			send_int(arr[i]); 
			uart_read_blocking();
		}
		send_int(cnt); 
		print(cnt);
		// for (int i = 0; i < len; i++) {
		// 	print(arr[i]);
		// }
		// unsigned int cnt = read_counter(); 
		// print(cnt);	
	}
}