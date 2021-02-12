.section .data 

.section .text.init 
.global _start 
_start: 
	# li sp, 2044
	# la a0, m_trap_vector
	# csrw mtvec, a0
	# la a1, KERNEL_TRAP_FRAME
	# csrw mscratch, a1
	la sp, _sp0

	# la a0, _heap_start
	# la a1, _heap_size
	# call kheap

	la ra, _endloop
	jal main

_endloop:
	j _endloop