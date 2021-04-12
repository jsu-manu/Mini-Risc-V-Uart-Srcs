#include"print.h" 
// #include"uart.h"

int tri(int n) {
	if (n <= 1) { 
		return n;
	}
	else return n + tri(n - 1);
}

int main(void) {
	int n = 96; 

	int tot = tri(n); 
	print(tot);
	return 0;
}

// int main(void) {
// 	int a = 3; 
// 	int tot = 0; 
// 	while(a > 0) {
// 		tot += a; 
// 		print(tot);
// 		a--; 
// 	}
// 	while(1); 
// 	return 0;
// }
