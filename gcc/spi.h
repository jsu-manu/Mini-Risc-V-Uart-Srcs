#ifndef SPI_H
#define SPI_H

#define SPI_BASE_ADDR 0xaaaaa500

void spi_write_ignore_response(char c);
char spi_write(char c); 
char spi_read(); 
char spi_poll(); 

#endif