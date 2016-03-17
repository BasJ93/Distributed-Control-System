#include <stdio.h>

int main(void)
{
	char data[11];
	char temp_char;
	char i = 0;

    int tmp = 235478;
    for(i = 0; i<11; i++)
    {
		temp_char = tmp % 10;
        data[i] = 48 + temp_char;
        tmp   = tmp/10;
		printf("%i\n", i);
    }
	char int_array[11];
	for(i = 0; i<11; i++)
	{
		if(data[9-i] != 48)
		{
			int j;
			for(j = 0; j<(11-i); j++)
			{
				printf("%c\n", data[9-i-j]);
				int_array[j] = data[9-i-j];
			}
			break;
		}
	} 
	int_array[10] = '\0';
	printf("%s\n", data);
	printf("%s\n", int_array);
	return 0;
}
