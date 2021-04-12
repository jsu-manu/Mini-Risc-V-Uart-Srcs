#include <stdio.h> 

typedef unsigned short uint16_t; 
typedef unsigned int uint32_t; 

uint32_t ROL(uint32_t a, int b) {
	return (a << b) | (a >> (32 - b));
}

uint32_t simon_round(uint32_t x0, uint32_t x1, uint32_t k0) {
	uint32_t x2; 
	uint32_t imm = ROL(x1, 1) & ROL(x1, 8); 
	x2 = x0 ^ imm; 
	x2 = x2 ^ ROL(x1, 2); 
	x2 = x2 ^ k0; 
	return x2; 
}

uint32_t simon_round_dec(uint32_t x2, uint32_t x1, uint32_t k0) {
	uint32_t x0; 
	x0 = x2 ^ k0; 
	x0 = x0 ^ ROL(x1, 2);
	uint32_t imm = ROL(x1, 1) & ROL(x1, 8); 
	x0 = x0 ^ imm; 
	return x0; 
}

int main(void) {

	uint32_t x0 = 0xaa; 
	uint32_t x1 = 0xbb; 
	uint32_t k0 = 0x11111111; 

	uint32_t x2 = simon_round(x0, x1, k0); 
	uint32_t x0p = simon_round_dec(x2, x1, k0); 

	printf("x0: %08x\nx2: %08x\nx0p: %08x\n", x0, x2, x0p);
	return 0;
}