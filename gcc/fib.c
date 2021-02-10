#include"print.h" 

int fib(int n) {
	if (n <= 1) return n;

	return fib(n-1) + fib(n-2);
}

int main(void) {
	int n = 9; 
	print(fib(n)); 
	return 0;
}