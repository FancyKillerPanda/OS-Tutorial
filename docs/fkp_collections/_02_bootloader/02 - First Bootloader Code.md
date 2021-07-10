---
layout: page
title:  "First Bootloader Code"
slug:  "first-bootloader-code"
date:   2021-07-10 11:33:37 +1000
---

In the last chapter, I mentioned that the BIOS loads the first sector of a drive and checks if it's a valid bootsector. You might now be wondering... how? How does it know if a sector is bootable, or just a regular sector of some drive?

To be marked as a bootable sector, the final two bytes (that's byte indices 510 and 511, since a sector is 512 bytes long) have to have a special value: `01010101 10101010`. When written in hex, these bytes would be `0x55` and `0xaa`, which is what we will put at the end of the sector.

You might also be wondering *where* exactly the BIOS loads the sector. After reading from the drive, does it put the sector at address 0 in RAM? Or some other address?
Well the answer is that it's some other address, namely `0x7c00`. Why `0x7c00`? History. So after the BIOS loads our sector (at the physical address of `0x7c00` in RAM), and after checking it's a bootsector, the BIOS will start executing whatever is at address `0x7c00`. Pretty neat, huh?

## A Basic Bootsector
### The Code
Let's create a new file, `boot/bootloader.asm`, and put this code in it. I'll also walk you through it line by line later.

```nasm
org 0x7c00

start:
	jmp start

end:
	times 510 - ($ - $$) db 0
	dw 0xaa55

```

### Running It
You can build the file by invoking NASM. The command is fairly straightforward, with `-o` indicating an output file name/type.

To run the binary file we just created in QEMU, invoke `qemu-system-i386`. The `-drive` flag defines a new drive, with an interface (`if`) of `floppy` (we're emulating a floppy drive). This is the first floppy drive (`index`), and it is a raw binary file (`format`).

```bash
mkdir bin
nasm src/boot/bootloader.asm -o bin/bootloader.bin
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=bin/bootloader.bin
```

If all goes to plan, you should see QEMU output "Booting from floppy...", and nothing else (we'll get to why soon). If you see QEMU output "No bootable device", you've done something wrong. Check the code again, and make sure your paths are correct.

I'll be putting these commands in bash files, just so I don't have to type them out each time I want to use them.

tools/build.sh (run this from the root directory):
```bash
#!/bin/bash

mkdir bin 2> /dev/null
cd bin

echo "Cleaning..."
rm *.bin *.img *.iso *.o *.vmdk 2> /dev/null

echo "Building..."
nasm ../src/boot/bootloader.asm -o bin/bootloader.bin || exit 1

echo "Running..."
qemu-system-i386 -drive if=floppy,index=0,format=raw,file=bin/bootloader.bin || exit 1

cd ..
exit 0
```

### So what does the code do?
Alright, let's walk through it line by line.

```nasm
org 0x7c00
```
This line tells NASM that we know we'll be loaded at `0x7c00`, and so we can think of ourselves there already. This will affect how addresses are handled internally.

```nasm
start:
```
This is a *label*, it doesn't get put into the final binary but instead just acts as a reference to a point in the code.

```nasm
jmp start
```
The `jmp` instruction jumps code execution to a specified place, in this case to the label `start`. You'll notice that this causes an infinite loop, which is why the program hangs after boot.

```nasm
times 510 - ($ - $$) db 0
```
There's a bit to unpack in this one, so we'll split it into two parts.

`db` is an instruction to "define byte", literally just put the value specified (in this case, `0`) directly into the final binary. There are other sizes you can use: `dw` ("define word", where a "word" is two bytes), `dd` ("define double-word", 4 bytes), `dq` ("define quad-word", 8 bytes). For example, `dd 0` will place 4 bytes of 0 into the final binary.

`times` is an instruction that tells NASM to repeat something a number of times, in our case it will repeat `db 0` `510 - ($ - $$)` times. The `$` means "the current location in the binary", the `$$` means "the start of the current section" (which is the start of the binary for us), and the `-` is a literal subtraction. So `($ - $$)` is simply calculating the number of bytes we've written in the binary up to that point.

`times 510 - ($ - $$)` as a whole is simply saying "repeat this for as many bytes we have left up to 510 bytes". Why 510 bytes? Recall a sector is 512 bytes long, and the final two bytes must have a specified value for the BIOS to recognise the bootsector as valid. Is it coming together now?

```nasm
dw 0xaa55
```
This is a simple insertion of values into the final binary, just like we did earlier. But, you might be saying, shouldn't it be `0x55` and *then* `0xaa`? Good catch, but it is already like that because of something called Little Endian.

Endianness is the order in which bytes are placed in a multibyte value. When writing out hex values, we always put the most significant byte (the one that means the most) on the left (at the start). In a Big Endian machine, the value `0x12345678` would have bytes ordered as `0x12 0x34 0x56 0x78` when outputted. However, x86 machines are Little Endian, and so the most significant byte goes *last*. In the example, `0x12345678` will be output as `0x78 0x56 0x34 0x12`.

And so doing `dw 0xaa55` will place the bytes in the binary as `0x55 0xaa`, which is exactly what we need! Of course, you could do a `db 0x55` followed by a `db 0xaa` in your source if you want, it'll act exactly the same way.

## Final Thoughts
So in this chapter we created an extremely basic bootsector, and ran it through QEMU. Experiment with the code you have currently, see what you can do to make the program boot or not boot. See you next time!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/854b39b42c54c0fbd4937b5e8de4c6e1c918880b).
