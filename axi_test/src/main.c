/*
 * Copyright (c) 2016 Bas Janssen
 *
 */

#include <stdio.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdbool.h>
//This library makes parsing command line arguments easy
#include <unistd.h>

//Ncurses allows us to make a graphical interface in a terminal.
#include <ncurses.h>
#include <form.h>

#define MAP_SIZE 4096L
#define MAP_MASK (MAP_SIZE - 1)

#define ADDR_BASE 0x43C00000

#define ALT_BACKSPACE 127

void *getvaddr(int phys_addr)
{
	void *mapped_base;
	int memfd;

	void *mapped_dev_base;
	off_t dev_base = phys_addr;

	memfd = open("/dev/mem", O_RDWR | O_SYNC); //To open this the program needs to run as root
		if(memfd == -1)
		{
			printf("Can't open /dev/mem. \n");
			exit(0);
		}

		mapped_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, dev_base & ~MAP_MASK);
			if(mapped_base == (void *) -1)
			{
				printf("Can't map the memory to user space.\n");
				exit(0);
			}

			mapped_dev_base = mapped_base + (dev_base & MAP_MASK);
			return mapped_dev_base;
}

void write_to_fpga(float * input_0, float * input_1, FIELD *field[5])
{
	if(field_status(field[0]))
		*(input_0) = atof(field_buffer(field[0], 0));
	if(field_status(field[1]))
		*(input_1) = atof(field_buffer(field[1], 0));
}

int main(int argc, char *argv[])
{
	FIELD *field[5];
	FORM *my_form;
	int ch;

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

	bool debug;
	int opt;

	while ((opt = getopt(argc, argv, "d")) != -1)
	{
		switch (opt)
		{
		case 'd' : debug = true; break;
		default: debug = false; break;
		}
	}

	init_pair(1, COLOR_WHITE, COLOR_BLUE);
	init_pair(2, COLOR_WHITE, COLOR_RED);
	init_pair(3, COLOR_BLACK, COLOR_WHITE);

	field[0] = new_field(1, 15, 4, 18, 0, 0);
	field[1] = new_field(1, 15, 6, 18, 0, 0);
	field[2] = new_field(1, 15, 4, 45, 0, 0);
	field[3] = new_field(1, 15, 6, 45, 0, 0);
	field[4] = NULL;

	set_field_fore(field[0], COLOR_PAIR(1));
	set_field_back(field[0], COLOR_PAIR(1));

	field_opts_off(field[0], O_AUTOSKIP);
	set_field_type(field[0], TYPE_NUMERIC, 10, 0.0000000, 20.0000000);

	set_field_fore(field[1], COLOR_PAIR(1));
	set_field_back(field[1], COLOR_PAIR(1));

	field_opts_off(field[1], O_AUTOSKIP);
	set_field_type(field[1], TYPE_NUMERIC, 10, 0.0000000, 20.0000000);

	set_field_fore(field[2], COLOR_PAIR(2));
	set_field_back(field[2], COLOR_PAIR(2));

	field_opts_off(field[2], O_AUTOSKIP);
	field_opts_off(field[2], O_ACTIVE);

	set_field_fore(field[3], COLOR_PAIR(2));
	set_field_back(field[3], COLOR_PAIR(2));

	field_opts_off(field[3], O_AUTOSKIP);
	field_opts_off(field[3], O_ACTIVE);

	my_form = new_form(field);
	post_form(my_form);
	refresh();

	set_current_field(my_form, field[0]);
	mvprintw(4, 10, "Input1:");
	mvprintw(6, 10, "Input2:");
	mvprintw(4, 35, "Output1:");
	mvprintw(6, 35, "Output2:");
	attron(COLOR_PAIR(3));
	mvprintw(2, 0, "Simple AXI interface test");
	mvprintw(8, 0, "Press F2 to exit");
	attroff(COLOR_PAIR(3));
	move(4,18);
	refresh();

	if (debug)
	{
		printf("Device base address: %x\n", ADDR_BASE);
		printf("Requesting base vaddress\n");
	}
	int * dev_base_vaddr = getvaddr(ADDR_BASE);
	if (debug)
		printf("Base address: %x\n", dev_base_vaddr);
	float * input_0 = dev_base_vaddr;
	if (debug)
		printf("Address input_0 %x\n", input_0);
	float * input_1 = dev_base_vaddr + 1;
	if (debug)
		printf("Address input_1 %x\n", input_1);
	float * output_0 = dev_base_vaddr + 2;
	if (debug)
		printf("Address output_0 %x\n", output_0);
	float * output_1 = dev_base_vaddr + 3;
	if (debug)
		printf("Address output_1 %x\n", output_1);

	char* output_0_val[15];
	char* output_1_val[15];

	//Process the keyboard input, exit with F2
	while((ch = getch()) != KEY_F(2))
	{
		switch(ch)
		{
		case KEY_DOWN:
			write_to_fpga(input_0, input_1, field);
			form_driver(my_form, REQ_NEXT_FIELD);
			form_driver(my_form, REQ_END_LINE);
			break;
		case KEY_UP:
			write_to_fpga(input_0, input_1, field);
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
		default:
			form_driver(my_form, ch);
			break;
		}

		sprintf(output_0_val, "%.11g", *(output_0));
		sprintf(output_1_val, "%.11g", *(output_1));
		set_field_buffer(field[2], 0, output_0_val);
		form_driver(my_form, REQ_END_LINE);
		set_field_buffer(field[3], 0, output_1_val);
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

	//Unmap the virtual address space
	munmap(dev_base_vaddr, MAP_SIZE);

	return(0);
}
