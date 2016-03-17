/*
 * Bas Jansse 2016
 * Fontys Hogeschool Engineering
 *
 */

#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <stddef.h>
#include <time.h>
#include <linux/spi/spidev.h>
#include <math.h>

//Ncurses allows us to make a graphical interface in a terminal.
#include <ncurses.h>
#include <form.h>

#define ALT_BACKSPACE 127

#define minAngle 0.72

static const char *spi_name = "/dev/spidev1.1";

int spiDev;

void write_spi_slave(int setpointAngle)
{
	int counts = setpointAngle / minAngle;
	int res;
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char rxBuffer[4];
	//Stop alle data in de struct
	xfer.tx_buf = (unsigned long)counts;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = 4;
	xfer.speed_hz = 5000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;
	//Verzend de data naar de slave
	res = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
}

float read_spi_slave()
{
	unsigned int address;
	float res;
	int counts;
	struct spi_ioc_transfer xfer;
	memset(&xfer, 0, sizeof(xfer));
	char rxBuffer[4];
	//Stop alle data in de struct
	xfer.tx_buf = (unsigned long)address;
	xfer.rx_buf = (unsigned long)rxBuffer;
	xfer.len = 4;
	xfer.speed_hz = 5000;
	xfer.cs_change = 0;
	xfer.bits_per_word = 8;
	//Verzend de data naar de slave
	counts = ioctl(spiDev, SPI_IOC_MESSAGE(1), &xfer);
	res = counts * minAngle;
	return res;
}

int main()
{
	FIELD *field[3];
	FORM *my_form;
	int ch;
	int angle_current;

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

	initscr();
	//Check if the terminal supports colors, if not exit the program.
	if(has_colors() == FALSE)
	{
		endwin();
		printf("Terminal does not support colors\n");
		exit(1);
	}

	//Enable the use of collors in the interface.
	start_color();
	//Enable the use of special keys in the interface.
	keypad(stdscr, TRUE);
	cbreak();
	//Disable caching the last used character in the cursor.
	noecho();

	init_pair(1, COLOR_WHITE, COLOR_BLUE);
	init_pair(2, COLOR_WHITE, COLOR_RED);
	init_pair(3, COLOR_BLACK, COLOR_WHITE);

	field[0] = new_field(1, 15, 4, 18, 0, 0);
	field[1] = new_field(1, 15, 6, 18, 0, 0);
	field[2] = NULL;

	set_field_fore(field[0], COLOR_PAIR(1));
	set_field_back(field[0], COLOR_PAIR(1));

	field_opts_off(field[0], O_AUTOSKIP);
	set_field_type(field[0], TYPE_NUMERIC, 2, 0, 0);

	set_field_fore(field[1], COLOR_PAIR(2));
	set_field_back(field[1], COLOR_PAIR(2));

	field_opts_off(field[1], O_AUTOSKIP);
	field_opts_off(field[1], O_ACTIVE);

	my_form = new_form(field);
	post_form(my_form);
	refresh();

	set_current_field(my_form, field[0]);
	mvprintw(4, 10, "Angle setpoint:");
	mvprintw(4, 35, "Current angle:");
	attron(COLOR_PAIR(3));
	mvprintw(2, 0, "STM32 PID controller test");
	mvprintw(8, 0, "Press F2 to exit");
	attroff(COLOR_PAIR(3));
	move(4,18);
	refresh();

	//Process the keyboard input, exit with F2
	while((ch = getch()) != KEY_F(2))
	{
		switch(ch)
		{
		case KEY_DOWN:

			form_driver(my_form, REQ_NEXT_FIELD);
			form_driver(my_form, REQ_END_LINE);
			break;
		case KEY_UP:

			form_driver(my_form, REQ_PREV_FIELD);
			form_driver(my_form, REQ_END_LINE);
			break;
		case KEY_LEFT:
			form_driver(my_form, REQ_PREV_CHAR);
			break;
		case KEY_RIGHT:
			form_driver(my_form, REQ_NEXT_CHAR);
			break;
		case KEY_BACKSPACE:
		case ALT_BACKSPACE:
			form_driver(my_form, REQ_DEL_PREV);
			break;
		case KEY_DC:
			form_driver(my_form, REQ_DEL_CHAR);
			break;
		case KEY_ENTER:
			//Send the data to the STM32
			break;
		default:
			form_driver(my_form, ch);
			break;
		}

		set_field_buffer(field[1], 0, angle_current);
		form_driver(my_form, REQ_END_LINE);
		refresh();

	}

	unpost_form(my_form);
	free_form(my_form);
	free_field(field[0]);
	free_field(field[1]);
	free_field(field[2]);
	free_field(field[3]);

	endwin();

    return 0;
}
