#include"counter.h" 

void zero_counter() {
	volatile char * ptr = (char *)0xaaaaa704;
	*(ptr) = 1; 
} 
char overflow_counter() {
	volatile char * ptr = (char *)0xaaaaa704;
	return *(ptr);
} 
unsigned int read_counter() {
	volatile unsigned int *ptr = (unsigned int *)0xaaaaa700; 
	return *ptr;
}