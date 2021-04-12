.section .text
.global main
main:
	addi a0,zero,10
	addi a0,a0,20
	ecall
	addi a0,a0,10
loop1:
	j loop1
	j main