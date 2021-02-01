#include"spi.h"
#include"print.h" 

int main(void) {
	spi_write_ignore_response(0x90); 
	spi_write_ignore_response(0);
	spi_write_ignore_response(0);
	spi_write_ignore_response(0);
	spi_write(0);
	spi_write(0); 

	while(!(spi_poll() & 1)); 

	char s = spi_read(); 
	print(s);
	// char c = 'a'; 
	// spi_write(c); 
	// while(!(spi_poll() & 1)); 
	// char s = spi_read(); 
	// print(s);
}