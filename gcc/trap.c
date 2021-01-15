#include"trap.h"
#include"uart.h"
#include"print.h"

void init_trap() {
	int i; 
	for (i = 0; i < 32; i++) {
		KERNEL_TRAP_FRAME.regs[i] = 0; 
	}
	KERNEL_TRAP_FRAME.trap_stack = 0;
}

uint m_trap(uint epc, uint mcause, uint status, uint frame) {

	// char mesg[] = "Trap has been triggered!\n";
	// uart_print(mesg);
	// init_trap();
	// while(1);
	char s = uart_poll();
	char c = uart_get();
	print(c);
	return epc;

}