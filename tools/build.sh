#!/bin/bash
#  ===== Date Created: 10 July, 2021 ===== 

mkdir bin 2> /dev/null
cd bin

echo "Cleaning..."
rm *.bin *.img *.iso *.o *.vmdk 2> /dev/null

echo "Building..."
nasm ../src/boot/bootloader.asm -I ../src/boot/ -o bootloader.bin || exit 1

echo "Running..."
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=bootloader.bin || exit 1

cd ..
exit 0
