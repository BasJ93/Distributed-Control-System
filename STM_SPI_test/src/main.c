#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stddef.h>
#include <time.h>
#include <linux/spi/spidev.h>

static const char *spi_name = "/dev/spidev1.1";

int main(void)
{
	//Maakt de struct voor de delay aan en vul deze met de gewenste tijd in seconden en nanoseconden.
	struct timespec sleeptime;

	sleeptime.tv_sec = 0;
	sleeptime.tv_nsec = 500000000;

	//Open het device dat de slave voorsteld.
	int spiDev = open(spi_name, O_RDWR);

	//De slave maakt gebruik van SPI mode 0, set de driver in dat deze modus gebruikt wordt.
	int mode = SPI_MODE_3;
	ioctl(spiDev, SPI_IOC_WR_MODE, &mode);

	//We sturen de data uit met het most significat bit eerst.
	int lsb = 0;
	ioctl(spiDev, SPI_IOC_WR_LSB_FIRST, &lsb);

	//Onze data bevat de standaard 8 bits per word.
	int bits_per_word = 0;
	ioctl(spiDev, SPI_IOC_WR_BITS_PER_WORD, &bits_per_word);

	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char txBuffer[] = {0x1F, 0xF1, 0x00, 0x00};
	char rxBuffer[2];
	//Stop alle data in de struct
	xfer.tx_buf = (unsigned long)txBuffer;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = 4;
	xfer.speed_hz = 5000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;
	//Verzend de data naar de slave
	int res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);

	if (res == 0)
		printf("Transmission successful\n");
	printf("Data: %x%x\n", rxBuffer[2], rxBuffer[3]);
	if(rxBuffer[3])
		printf("Command failed\n");
	else
		printf("Command successful\n");

	return 0;
}
