#!/bin/bash

sh -c 'cd ramdisk/ && sudo find . | sudo cpio -H newc -o' | gzip -9 > new_initramfs.cpio.gz
~/xilinx-uboot/u-boot-xlnx/tools/mkimage -A arm -T ramdisk -C gzip -d ~/workspace/new_initramfs.cpio.gz ~/workspace/uramdisk.image.gz
