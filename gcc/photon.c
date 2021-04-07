// #include"uart.h"
// #include"print.h"
#include"utils.h"

int main(void) {
	// uart_init();

	// char h1[] = "Photon Test\r\n";
	// uart_print(h1);
	int test = 0;

	int result[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
	// Result should be :
	// 0x17304242, 0x9CF26E10, 0x8D3D9CF9, 0x00E27BDC,
	// 0xC629B3D1, 0xAF41F1CB, 0x7483FCC0, 0x8916B82C
	// Or in decimal as it will be printed:
	//  389038658, -1661833712, -1925341959,    14842844
	// -970345519, -1354632757,  1954806976, -1994999764

	// char h4[] = "Hashing data...\r\n";
	// uart_print(h4);

	// Load data into RISC-V registers (must be modified in assembly)
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0x00382020;

	// Load data into Photon (must be modified in assembly)
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;
	test = 0;


	int status = 0; // hash
	do {
		// Read Photon control reg. into status register
		status = 0; // plw a5, ctrl (must be modified in assembly)
		status = 0; // nop
		status = 0; // nop
		status = 0; // nop
		// nop
	} while (status == 0); // beqz a5, #do

	// char h5[] = "Retrieving result of hash\r\n";
	// uart_print(h5);

	test = 0; // mlw a0,pho_result[0]
	test = 0; // mlw a1,pho_result[1]
	test = 0; // mlw a2,pho_result[2]
	test = 0; // mlw a3,pho_result[3]
	test = 0; // mlw a4,pho_result[4]
	test = 0; // mlw a5,pho_result[5]
	test = 0; // mlw a6,pho_result[6]
	test = 0; // mlw a7,pho_result[7]

	result[0] = test;
	result[1] = test;
	result[2] = test;
	result[3] = test;
	result[4] = test;
	result[5] = test;
	result[6] = test;
	result[7] = test;

	// char num_str[16];
	// char* space = " ";
	// for (int i = 0; i < 8; i++) {
	// 	itoa(result[i], num_str);
	// 	uart_print(num_str);
	// 	uart_print(space);
	// }

	return 0;
}
