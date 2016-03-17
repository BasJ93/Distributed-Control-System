/****************************/
/*							*/
/*	Author: Bas Janssen		*/
/*	Copyright 2016			*/
/*							*/
/****************************/

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <stddef.h>
#include <time.h>
#include <linux/spi/spidev.h>
#include <math.h>

static const char *spi_name = "/dev/spidev1.1";

static const char numbers[] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0xFD, 0x07, 0xFF, 0x6F, 0x3F, 0x06, 0x5B};

int main()
{
	//Maakt de struct voor de delay aan en vul deze met de gewenste tijd in seconden en nanoseconden.
	struct timespec sleeptime;

	sleeptime.tv_sec = 0;
	sleeptime.tv_nsec = 500000000;

	int res;
	//Open het device dat de slave voorsteld.
	int spiDev = open(spi_name, O_RDWR);

	//De slave maakt gebruik van SPI mode 0, set de driver in dat deze modus gebruikt wordt.
	int mode = SPI_MODE_0;
	ioctl(spiDev, SPI_IOC_WR_MODE, &mode);

	//We sturen de data uit met het most significat bit eerst.
	int lsb = 0;
	ioctl(spiDev, SPI_IOC_WR_LSB_FIRST, &lsb);

	//Onze data bevat de standaard 8 bits per word.
	int bits_per_word = 0;
	ioctl(spiDev, SPI_IOC_WR_BITS_PER_WORD, &bits_per_word);

	//Deze struct is de placeholder voor de SPI transacties
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));

	//Stuur een reset commando naar het schermpje
	char dataBuffer[] = {0x7A, 0xFF};
	char rxBuffer[2];
	//Stop alle data in de struct
	xfer.tx_buf = (unsigned long)0x76;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = 2;
	xfer.speed_hz = 5000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;
	//Verzend de data naar de slave
	res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
	//Slaap voor de ingestelde tijd
	nanosleep(&sleeptime, NULL);
	//Zet alle puntjes op het schermpje aan
	dataBuffer[0] = 0x77;
	dataBuffer[1] = 0xFF;
	xfer.tx_buf = (unsigned long)dataBuffer;
	res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
//	printf("Results: %x\t%x\n", rxBuffer[1], rxBuffer[0]);
	nanosleep(&sleeptime, NULL);
	//Zet de puntjes weer uit
	dataBuffer[0] = 0x77;
	dataBuffer[1] = 0x00;
	xfer.tx_buf = (unsigned long)dataBuffer;
	res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
//	printf("Results: %x\t%x\n", rxBuffer[1], rxBuffer[0]);
	nanosleep(&sleeptime, NULL);
	//Stel de eerste digit in om het cijfer 8 te weergeven
	char dataBuffer2[2];
	char rxBuffer2[2];
	while (1)
	{
		int i;
		for(i=0; i<10; i++)
		{
			//Stop de data in de struct
			dataBuffer2[0] = 0x7B;
			dataBuffer2[1] = numbers[i];
			xfer.tx_buf = (unsigned long)dataBuffer2;
			xfer.rx_buf = (unsigned long)rxBuffer2;
			xfer.len = 2;
			res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
			printf("Results: %x\t%x\n", rxBuffer2[1], rxBuffer2[0]);
			//Stel de tweede digit in op 3
			dataBuffer2[0] = 0x7C;
			dataBuffer2[1] = numbers[i+1];
			xfer.tx_buf = (unsigned long)dataBuffer2;
			res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
			printf("Results: %x\t%x\n", rxBuffer2[1], rxBuffer2[0]);
			//Stel de derde digit in op 1
			dataBuffer2[0] = 0x7D;
			dataBuffer2[1] = numbers[i+2];
			xfer.tx_buf = (unsigned long)dataBuffer2;
			res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
			printf("Results: %x\t%x\n", rxBuffer2[1], rxBuffer2[0]);
			//Stel de vierde digit in op 0
			dataBuffer2[0] = 0X7E;
			dataBuffer2[1] = numbers[i+3];
			xfer.tx_buf = (unsigned long)dataBuffer2;
			res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
			printf("Results: %x\t%x\n", rxBuffer2[1], rxBuffer2[0]);
			nanosleep(&sleeptime, NULL);
		}
	}
	return(0);
}
