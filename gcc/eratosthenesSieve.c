#include "print.h"
#include "counter.h"

int main(void) {
	// 2, 3, 5, 7, 11, 13, 17, 19, 23, 29
	int prime[100];
	int n = 100;

	zero_counter();

	// Initialize sieve to all prime
	for (int i = 0; i < n; i++)
		prime[i] = (i > 1);

	// Eliminate composites from prime candidates
	for (int i = 2; i < 10 /*sqrt(100)*/; i++)
		if (prime[i] == 1)
			for (int j = 0; (i*i)+(j*i) < n; j++)
				prime[(i*i)+(j*i)] = 0;

	// Count remaining primes
	int primeCount = 0;
	for (int i = 0; i < n; i++)
		if (prime[i])
			primeCount++;

	print(read_counter());
}
