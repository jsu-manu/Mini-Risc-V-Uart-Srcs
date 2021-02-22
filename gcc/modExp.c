#include "print.h"
#include "counter.h"
#include "CRAS.h"

int modular_exp(int base, int exponent, int modulus) {
	if (exponent == 1)
		return 0;

	int result = 1;
	base %= modulus;
	while (exponent > 0) {
		if (exponent % 2 == 1)
			result = (result * base) % modulus;
		exponent >>= 1;
		base = (base * base) % modulus;
	}
	return result;
}

int main(void) {
	set_CRAS(1);
	zero_counter();
	int val1 = modular_exp(5, 3, 13); // = 8
	int val2 = modular_exp(2, 90, 13); // = 12

	print(read_counter());
	print(val1);
	print(val2);
	return 0;
}
