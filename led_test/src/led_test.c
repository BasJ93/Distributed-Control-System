/*
 * led_test.c
 *
 *  Created on: Feb 16, 2016
 *      Author: bas
 */


#include <stdio.h>
#include <time.h>

int main()
{
	FILE *led1;
	FILE *led2;

	struct timespec sleeptime;

	sleeptime.tv_sec = 0;
	sleeptime.tv_nsec = 125000000;

	while(1)
	{
		led1 = fopen("/sys/class/gpio/gpio61/value", "w");
		led2 = fopen("/sys/class/gpio/gpio62/value", "w");
		fputc('0', led1);
		fputc('1', led2);
		fclose(led1);
		fclose(led2);
		nanosleep(&sleeptime, NULL);
		led1 = fopen("/sys/class/gpio/gpio61/value", "w");
		led2 = fopen("/sys/class/gpio/gpio62/value", "w");
		fputc('1', led1);
		fputc('0', led2);
		fclose(led1);
		fclose(led2);
		nanosleep(&sleeptime, NULL);
	}

	fclose(led1);
	fclose(led2);

	return(0);
}
