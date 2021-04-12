#include"print.h"

void printl(int l[], int llen) {
	int i = 0; 
	for (i = 0; i < llen; i++) 
		print(l[i]);
	print(105); 
}

int main(void) {
	int l[] = {5,1,4,2,8};
	int llen = 5;
	printl(l, llen);
	int swapped = 1;	
	while(swapped) {
		swapped = 0;
		int i = 1; 
		for (i = 1; i < llen; i++) {
			if (l[i-1] > l[i]) {
				int tmp = l[i];
				l[i] = l[i-1];
				l[i-1] = tmp; 
				swapped = 1;
			}
		}
	}
	printl(l, llen);
	return 0;

}

