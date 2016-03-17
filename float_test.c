#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

int main()  
{  
    int32_t test = 4756700; 
    char result[sizeof(int32_t)];
    int32_t count = sizeof(int32_t);
    memcpy(result, &test, sizeof(test));

    /* now result is storing the float,
           but you can treat it as an array of 
           arbitrary chars

       for example:
    */
    printf("%i\n", test);
    printf("Count:%i\n", count);
    int n;
    for (n = 0; n < count; ++n) 
        printf("%x", result[n]);
    printf("\n");

	printf("%x%x%x%x\n", result[0], result[1], result[2], result[3]);
	printf("%x\n", result[0]);
    return 0;  
}  
