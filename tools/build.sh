#!/bin/bash
#  ===== Date Created: 10 July, 2021 ===== 

# Flags
kernelCompileFlags="-ffreestanding -nostdinc -nostdinc++ \
					-Wall -Wextra \
					-o kernel.bin -target i386-pc-none-elf \
					-I ../src/kernel/"
kernelLinkFlags="-nostdlib -Wl,--oformat=binary,-T../src/kernel/linkScript.ld"
kernelFiles="../src/kernel/unityBuild.cpp kernelEntryPoint.o"

# Build
mkdir bin 2> /dev/null
cd bin

echo -e "Cleaning..."
rm *.bin *.img *.iso *.o *.vmdk 2> /dev/null

echo -e "\nBuilding..."
nasm ../src/boot/bootloader.asm -I ../src/boot/ -o bootloader.bin || exit 1
nasm -felf32 ../src/kernel/entryPoint.asm -o kernelEntryPoint.o || exit 1
clang++ $kernelCompileFlags $kernelLinkFlags $kernelFiles || exit 1

../tools/genVDisk --output "OS-Tutorial.img" --floppy \
				  --bootloader bootloader.bin --kernel kernel.bin

echo -e "\nRunning..."
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=OS-Tutorial.img || exit 1

cd ..
exit 0
