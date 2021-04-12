#include "print.h" 

// void print(int a) {
// 	int addr = 0; 
// 	int wr = 1;
// 	__asm__("li %[c], 1\n\t"
// 			"li %[b], 0\n\t"
// 			"lui %[b], 699050\n\t"
// 			"sw %[a],8(%[b])\n\t"
// 			"sw %[c],4(%[b])\n\t"
// 			"sw zero,4(%[b])"
// 			: : [a] "r" (a), [b] "r" (addr), [c] "r" (wr) );
// }

void print(int a) {
    // volatile int * p = (int *)0xaaaaa008;
    // *p = a;
    int addr = 0;
    __asm__("li  %[b], 0\n\t"
            "lui %[b], 699050\n\t"
            "sw %[a],8(%[b])"
            : : [a] "r" (a), [b] "r" (addr)
        );
}

/*
void printchar(char a) {
    __asm__("li a1, 1\n\t"
            "li a5, 0\n\t"
            "lui a5, 699050\n\t"
            "sw %[a],8(a5)\n\t"
            "sw a1,4(a5)\n\t"
            "sw zero,4(a5)"
            : : [a] "r" (a): "a1", "a4", "a5");
}

void printptr(char* a) {
    __asm__("li a1, 1\n\t"
            "li a5, 0\n\t"
            "lui a5, 699050\n\t"
            "sw %[a],8(a5)\n\t"
            "sw a1,4(a5)\n\t"
            "sw zero,4(a5)"
            : : [a] "r" (a): "a1", "a4", "a5");
}
*/
