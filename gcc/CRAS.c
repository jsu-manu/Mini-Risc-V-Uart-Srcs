#include"CRAS.h" 

void set_CRAS(char c) {
	volatile char * ptr = (char *)0xaaaaa600; 
	*ptr = c; 
}
void set_key_word(unsigned int k[4]) {
	volatile unsigned int * ptr = (unsigned int *)0xaaaaa604;
	*ptr = k[0];
	*(ptr + 1) = k[1];
	*(ptr + 2) = k[2];
	*(ptr + 3) = k[3];
}

