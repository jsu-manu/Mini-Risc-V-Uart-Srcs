.option norvc
.altmacro
.set NUM_GP_REGS, 32  # Number of registers per context
.set REG_SIZE, 4   # Register size (in bytes)

# Use macros for saving and restoring multiple registers
.macro save_gp i, basereg=t6
	sw	x\i, ((\i)*REG_SIZE)(\basereg)
.endm
.macro load_gp i, basereg=t6
	lw	x\i, ((\i)*REG_SIZE)(\basereg)
.endm

.section .text
.global m_trap_vector
.align 4
m_trap_vector: 
	csrrw t6, mscratch, t6
	.set i, 0
	.rept 31
		save_gp %i
		.set i, i+1 
	.endr 

	mv t5, t6 
	csrr t6, mscratch 
	save_gp 31, t5 

	csrw mscratch, t5

	csrr a0, mepc
	# sw a0, 132(t5) 
	csrr a1, mtval
	csrr a2, mcause
	#csrr a3, mhartid
	csrr a3, mstatus
	csrr a4, mscratch 
	la   sp, _sp1

	call m_trap

	csrw mepc, a0
	csrr t6, mscratch 

	.set i, 1
	.rept 31
		load_gp %i
		.set i, i+1 
	.endr 


	mret