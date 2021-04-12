#include"trap.h"
#include"uart.h"

void init_trap() {
	int i; 
	for (i = 0; i < 32; i++) {
		KERNEL_TRAP_FRAME.regs[i] = 0; 
	}
	KERNEL_TRAP_FRAME.trap_stack = 0;
}

uint m_trap(uint epc, uint mcause, uint status, uint frame) {

	while(1);

	return 0;

}