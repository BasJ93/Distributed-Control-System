/*
 * Copyright (c) 2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include <stdio.h>
#include <linux/spi/spidev.h>
#include <sys/ioctl.h>
#include <stddef.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>


#define READ 0x03
#define WRITE 0x04
#define REG_TYPE 0x00
#define WAIT_STATE 0xFF

static const char *spi_name = "/dev/spidev1.1";

int main()
{

	uint16_t address;
	char cmd[6];
	address = 0x0000;
	cmd[0] = 0x00;
	cmd[1] = 0x03;
	cmd[2] = WAIT_STATE;
	cmd[3] = 0x00;
	cmd[4] = 0x00;
	cmd[5] = 0xFF;

	int res;
	//Open het device dat de slave voorsteld.
	int spiDev = open(spi_name, O_RDWR);

	//De slave maakt gebruik van SPI mode 3, set de driver in dat deze modus gebruikt wordt.
	int mode = SPI_MODE_3;
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
	char rxBuffer[6];
	//Stop alle data in de struct
	xfer.tx_buf = (unsigned long)cmd;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = 6;
	xfer.speed_hz = 5000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;
	//Verzend de data naar de slave
	while(1)
	{
		res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);

		printf("Transfer: %x%X%X%X%X%X\n", cmd[0], cmd[1], cmd[2], cmd[3], cmd[4], cmd[5]);
		printf("Result: %x%x%x%x%x%x\n", rxBuffer[0], rxBuffer[1], rxBuffer[2], rxBuffer[3], rxBuffer[4], rxBuffer[5]);
	}
    return 0;
}
