	 /* Somma di 10 valori interi */
#include <stdio.h>

const long int values[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

int main() {
	long int result;
	
	result = 0;
	for (int i = 0; i < 10; i++){
		result = result + values[i];
	} 
}