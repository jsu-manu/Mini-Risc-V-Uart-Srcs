#include "print.h"
#include "counter.h"

int main(void) {
	int a = 1;
	int b = 1;
	int tmp;

	zero_counter();

	// Calculate Fibonacci sequence via loop
	for (int n = 2; n < 9; n++) {
		tmp = b;
		b = a + b;
		a = tmp;
	}

	print(read_counter());

	return 0;
}
