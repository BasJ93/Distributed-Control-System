#Export the target ARCH and CC
export ARCH:=arm
export CROSS_COMPILE:=arm-xilinx-linux-gnueabi-

# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language.
ifneq ($(KERNELRELEASE),)
	obj-m := PID.o
# Otherwise we were called directly from the command
# line; invoke the kernel build system.
else
	KERNELDIR ?= /home/bas/linux-xlnx
	PWD  := $(shell pwd)
	BUILD := $(PWD)/build
default:
	$(MAKE) -C $(KERNELDIR) M=$(BUILD) src=$(PWD) modules
	mv build/PID.ko Debug/PID.ko
# If we run make install, copy the module to the Zynq using scp
install:
	$(MAKE) -C $(KERNELDIR) M=$(BUILD) src=$(PWD) modules
	mv build/PID.ko Debug/PID.ko
	scp Debug/PID.ko root@$(BOARD):/media/card
endif
