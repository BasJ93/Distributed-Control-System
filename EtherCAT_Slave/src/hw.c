#include "ecat_def.h"

#include <stdio.h>
#include <linux/spi/spidev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>

static const char *spi_name = "/dev/spidev1.1";
static int spidev = 0;

uint64_t lastTime;

UINT8 HW_Init(void)
{
	spidev = open(spi_name, O_RDWR);
	ioctl(spidev, SPI_IOC_WR_MODE, SPI_MODE_3);
	ioctl(spidev, SPI_IOC_WR_LSB_FIRST, 0);
	ioctl(spidev, SPI_IOC_WR_BITS_PER_WORD, 0);
	return 0;
}

void HW_Release(void)
{
	close(spidev);
}

void HW_SetLed(UINT8 RunLed, UINT8 ErrLed)
{

}

void HW_EscRead(MEM_ADDR *pData, UINT16 Address, UINT16 Len)
{
	//This might work.
	int res = -1;
	//This struct is used as a placeholder for the spidev spi transaction.
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char cmd[3+Len];
	cmd[0] = 0x03;
	cmd[1] = *((UINT8*)&Address+1);
	cmd[2] = *((UINT8*)&Address+0);
	int i = 0;
	for(i=0; i<Len; i++)
	{
		cmd[3+i] = 0xFF;
	}
	char rxBuffer[sizeof(cmd)/sizeof(char)];
	//Place all data in into the struct.
	xfer.tx_buf = (unsigned long)cmd;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = sizeof(cmd)/sizeof(char);
	xfer.speed_hz = 500000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;

	//Transmit the data to the slave.
	res = ioctl(spidev, SPI_IOC_MESSAGE(1), &xfer);
	if(res)
	{
		for(i=0; i<Len; i++)
		{
			pData[i] = rxBuffer[3+i];
		}
	}
}

void HW_EscReadIsr(MEM_ADDR *pData, UINT16 Address, UINT16 Len)
{
	//This might work.
	int res = -1;
	//This struct is used as a placeholder for the spidev spi transaction.
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char cmd[3+Len];
	cmd[0] = 0x03;
	cmd[1] = *((UINT8*)&Address+1);
	cmd[2] = *((UINT8*)&Address+0);
	int i = 0;
	for(i=0; i<Len; i++)
	{
		cmd[3+i] = 0xFF;
	}
	char rxBuffer[sizeof(cmd)/sizeof(char)];
	//Place all data in into the struct.
	xfer.tx_buf = (unsigned long)cmd;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = sizeof(cmd)/sizeof(char);
	xfer.speed_hz = 500000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;

	//Transmit the data to the slave.
	res = ioctl(spidev, SPI_IOC_MESSAGE(1), &xfer);
	if(res)
	{
		for(i=0; i<Len; i++)
		{
			pData[i] = rxBuffer[3+i];
		}
	}
}

void HW_EscWrite(MEM_ADDR *pData, UINT16 Address, UINT16 Len)
{
	//This might work.
	int res = -1;
	//This struct is used as a placeholder for the spidev spi transaction.
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char cmd[3+Len];
	cmd[0] = 0x02;
	cmd[1] = *((UINT8*)&Address+1);
	cmd[2] = *((UINT8*)&Address+0);
	int i = 0;
	for(i=0; i<Len; i++)
	{
		cmd[3+i] = pData[i];
	}
	char rxBuffer[sizeof(cmd)/sizeof(char)];
	//Place all data in into the struct.
	xfer.tx_buf = (unsigned long)cmd;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = sizeof(cmd)/sizeof(char);
	xfer.speed_hz = 500000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;

	//Transmit the data to the slave.
	res = ioctl(spidev, SPI_IOC_MESSAGE(1), &xfer);
}

void HW_EscWriteIsr(MEM_ADDR *pData, UINT16 Address, UINT16 Len)
{
	//This might work.
	int res = -1;
	//This struct is used as a placeholder for the spidev spi transaction.
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char cmd[3+Len];
	cmd[0] = 0x02;
	cmd[1] = *((UINT8*)&Address+1);
	cmd[2] = *((UINT8*)&Address+0);
	int i = 0;
	for(i=0; i<Len; i++)
	{
		cmd[3+i] = pData[i];
	}
	char rxBuffer[sizeof(cmd)/sizeof(char)];
	//Place all data in into the struct.
	xfer.tx_buf = (unsigned long)cmd;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = sizeof(cmd)/sizeof(char);
	xfer.speed_hz = 500000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;

	//Transmit the data to the slave.
	res = ioctl(spidev, SPI_IOC_MESSAGE(1), &xfer);
}

void HW_EscReadWord(UINT16 *WordValue, UINT16 Address)
{
	HW_EscRead(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),2);
}

void HW_EscReadWordIsr(UINT16 *WordValue, UINT16 Address)
{
	HW_EscReadIsr(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),2);
}

void HW_EscReadDWord(uint32_t *WordValue, UINT16 Address)
{
	HW_EscRead(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),4);
}

void HW_EscWriteWord(UINT16 *WordValue, UINT16 Address)
{
	HW_EscWrite(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),2);
}

void HW_EscWriteWordIsr(UINT16 *WordValue, UINT16 Address)
{
	HW_EscWriteIsr(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),2);
}

void HW_EscWriteDWord(UINT32 *WordValue, UINT16 Address)
{
	HW_EscWrite(((MEM_ADDR *)&(WordValue)),((UINT16)(Address)),4);
}

unsigned long HW_GetTimer()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec*(uint64_t)1000000+tv.tv_usec - lastTime);
}

void HW_ClearTimer()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	lastTime = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
}

void HW_EscReadMbxMem(MEM_ADDR *pData, UINT16 Address,UINT16 Len)
{
	HW_EscRead(((MEM_ADDR *)(pData)),((UINT16)(Address)),(Len));
}

void HW_EscWriteMbxMem(MEM_ADDR *pData,UINT16 Address,UINT16 Len)
{
	HW_EscWrite(((MEM_ADDR *)(pData)),((UINT16)(Address)),(Len));
}

UINT16 HW_GetALEventRegister(void)
{
	return 0;
}

UINT16 HW_GetALEventRegister_Isr(void)
{
	return 0;
}

void DISABLE_ESC_INT(void)
{

}

void ENABLE_ESC_INT(void)
{

}
