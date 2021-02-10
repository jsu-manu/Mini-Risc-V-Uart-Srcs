#include"print.h" 

void swap(int *a, int *b) {
	int t = *a; 
	*a = *b; 
	*b = t; 
}

int partition(int arr[], int low, int high) {
	int pivot = arr[high]; 
	int i = (low - 1); 

	for (int j = low; j <= high - 1; j++) {
		if (arr[j] < pivot) {
			i++; 
			swap(&arr[i], &arr[j]); 
		}
	}
	swap(&arr[i+1], &arr[high]); 
	return (i + 1); 
}

void quicksort(int arr[], int low, int high) {
	if (low < high) {
		int pi = partition(arr, low, high); 
		quicksort(arr, low, pi - 1); 
		quicksort(arr, pi + 1, high);
	}
}


int main(void) {
	// int len = 6;
	// int arr[] = {3, 2, 5, 1, 7, 6}; 
	int len = 32; 
	int arr[len]; 
	for (int i = 0; i < len; i++) {
		arr[i] = len - i; 
	}
	quicksort(arr, 0, len-1);
	for (int i = 0; i < len; i++) {
		print((char)arr[i]);
	}
}