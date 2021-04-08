/*
	This program demonstrates a buffer overflow attack 
	using memcpy to rewrite the return address of main() in the stack. 
	Overwrites the return address to point to badfunc() where it prints 100 to the 
	7 seg display and hangs within the function. 
	You can verify that it is in badfunc by using objdump and compare the program
	counter's location.
*/
#include"print.h"
#include"memcpy.h"
#include"CRAS.h"
// #include<stdio.h> 

extern int _rp0;

void badfunc() {
	// printf("This is a secret function ;)\n");
	print(100);
	while(1);

}


void vuln_func(int x, int i) {
	char buf[8];
	if (i == 0) {
		void (*fun_ptr)(void) = &badfunc;
		print(x); 
		memcpy(buf + 24, &fun_ptr, sizeof(size_t)); 
		vuln_func(x, i+1);
	} else if (i == 64) {
		volatile int * badptr = (int *)(0x20244);
		*(badptr) = (int)(&badfunc); 
		return;
	} else {
		vuln_func(x, i+1);
	}
	return;
}

int main(void) {
	set_CRAS(1);
	// char buf[8]; 
	// void (*fun_ptr)(void) = &badfunc; 
	// print(0x100);
	// memcpy(buf + 20, &fun_ptr, sizeof(size_t));
	vuln_func(0x100, 0);

	return 0;
}
