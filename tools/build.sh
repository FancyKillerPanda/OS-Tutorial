#!/bin/bash
#  ===== Date Created: 10 July, 2021 ===== 

mkdir bin 2> /dev/null
cd bin

echo "Cleaning..."
rm *.bin *.img *.iso *.o *.vmdk 2> /dev/null

echo "Building..."
nasm ../src/boot/bootloader.asm -I ../src/boot/ -o bootloader.bin || exit 1

touch kernel.bin
../tools/genVDisk --output "OS-Tutorial.img" --floppy \
				  --bootloader bootloader.bin --kernel kernel.bin

echo "Running..."
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=OS-Tutorial.img || exit 1

cd ..
exit 0
