#include"print.h" 

void secret_function() {
	print(0x69); 
}

void vuln_function(char c[4], int len) {
	for (int i = 0; i < 32; i++) {
		*(c + i) = 0; 
	}
	return;
}

int main(void) {
	char c[4];
	int len = 6; 
	vuln_function(c, len); 
	return 0;
}