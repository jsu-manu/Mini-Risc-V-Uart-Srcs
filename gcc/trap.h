#ifndef TRAP_H
#define TRAP_H

typedef unsigned int uint;

struct trapframe {
	uint regs[32];
	uint trap_stack; 
};

typedef struct trapframe TrapFrame;

TrapFrame KERNEL_TRAP_FRAME;

void init_trap();

uint m_trap(uint epc, uint mcause, uint status, uint frame);

#endif