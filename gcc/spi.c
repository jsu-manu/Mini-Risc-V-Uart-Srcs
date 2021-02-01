#include"spi.h" 

void spi_write_ignore_response(char c) {
	volatile int * ptr = (int *)SPI_BASE_ADDR; 
	*(ptr) = (1 << 9) & c; 
}
char spi_write(char c) {
	volatile char * ptr = (char *)SPI_BASE_ADDR;
	*(ptr) = c;
} 

char spi_read() {
	volatile char * ptr = (char *)SPI_BASE_ADDR; 
	return *ptr; 
}
char spi_poll() {
	volatile char * ptr = (char *)SPI_BASE_ADDR;
	return *(ptr + 1);
} 