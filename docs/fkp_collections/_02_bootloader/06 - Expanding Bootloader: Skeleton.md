---
layout: page
title:  "Expanding Bootloader: Skeleton"
slug:  "skeleton-expanding-bootloader"
date:   2021-07-11 10:09:17 +1000
---

In this chapter, we'll look at the theory behind an expanding bootloader, as well as implementing a skeleton for it (we'll do detailed implementations in the next chapter). This is quite a long chapter, so read it in parts if you need.

## BIOS Parameter Block
### What is it?
The BIOS parameter block is a series of values placed in our bootloader that help the BIOS identify the filesystem of the drive that is being booted, as well as the "geometry" of the loaded disk. Drives are often composed of multiple disks (called platters), with read/write heads on each. The geometry of the drive basically just describes the layout of the disks, where data gets stored.

You can read more about it [here](https://wiki.osdev.org/FAT) and [here](https://en.wikipedia.org/wiki/BIOS_parameter_block#FAT32).

### Do we need it?
Different BIOSs are different and they may read some or none of the BPB. In my testing, I've had no issues with not using a BPB, however I have reserved space for it (by zeroing out) just in case I need it in the future when I start reading from a filesystem.

### Alright, where do we put it?
The BIOS parameter block must begin 3 bytes into the final binary, and will run for 87 bytes (for FAT32). We can modify our start function to jump past the BPB, as the BPB is data, not code.

```nasm
start:
	jmp short main
	nop

biosParameterBlock: times 87 db 0

main:
	jmp $
```

Here you can see that all that happens in `start` is a short jump (the `short` indicates this to be a relative jump to somewhere nearby) to `main`, skipping over the BPB. The `nop` instruction is one of "no operation", it does nothing but still takes up space. Why, you might ask? Recall the BPB must start after 3 bytes, yet the `jmp` instruction only takes up 2 bytes. So we pad with one extra instruction byte.

## The `main` Function
### Segments
When we get into `main`, the first thing we should do is set up our segments (we wanto to simply zero them out for now). We also set up our bootloader stack, giving the stack pointer `sp` an address to work from (this was fairly arbitrary, see [this page](https://wiki.osdev.org/Memory_Map_(x86)#Overview) for what is and isn't usable).

```nasm
.setup:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov sp, 0xb000
```

### Boot Drive Number
The boot drive number is a number passed to us by the BIOS, through the register `dl` (in fact, `dl` is the *only* register which we can guarantee has a usable value when we begin). The boot drive number indicates which drive we booted from, floppy drives begin at 0 and hard drives begin at 128. This number is used by some BIOS interrupts later, so we should save it in a variable.

Variables are defined simply as labels, with a "define" instruction (`db`, `dw`, etc.) after it. Let's put this at the bottom of our file (above the end of the first sector code, where we pad with zeroes and write out `0xaa55`). In this case, we only need a single byte for this value.
```nasm
bootDriveNumber: db 0
```
To set the value, we should do this after we set up our segments.
```nasm
mov [bootDriveNumber], dl
```

## Some Utility Functions
We already have a `print_string` function, let's create some implementations for `clear_screen` and `reboot`.

### The `clear_screen` Function
```nasm
; void clear_screen()
clear_screen:
	.clear:
		mov ax, 0x0700			; Entire screen
		mov bx, 0x07			; Colour (black background, white foreground)
		xor cx, cx				; Top-left of screen is (0, 0)
		mov dx, 0x184f			; Screen size: 24 rows x 79 columns
		int 0x10

	.move_cursor:
		mov ax, 0x02
		xor dx, dx				; Move to (0, 0)
		xor bh, bh				; Page 0
		int 0x10

	.cleanup:
		ret
```

### The `reboot` Function
This function will print a string to the user, and then wait for a key to be pressed before restarting.

```nasm
; void reboot()
reboot:
	.notify:
		mov si, rebootMessage
		call print_string

	.wait_for_key_press:
		xor ax, ax
		int 0x16

	.restart:
		jmp word 0xffff:0x0000
```

We also need to define the `rebootMessage`, which can be done as such:
```nasm
rebootMessage: db "Press any key to reboot...", CR, LF, 0
```

### Moving Functions Away
The `bootloader.asm` file is starting to get a little large, let's move the utility functions away into a separate file that we can include in the main one. I generally like to suffix assembly file names with `-inl` if they'll just be included, not compiled. So let's do that!

Create a new file `utility-inl.asm`, and put the `reboot`, `clear_screen`, and `print_string` functions in there. Then we'll add this line to our `bootloader.asm` file, where those functions used to be:
```nasm
%include "utility-inl.asm"
```

To make this happen, we'll also need to modify the build file to add an additional include directory, just like we would when programming in C/C++. This is the new compilation line:
```bash
nasm ../src/boot/bootloader.asm -I ../src/boot/ -o bootloader.bin || exit 1
```

### Finishing Up `.setup`
To finish up under the `.setup` label, let's clear the screen and print out a welcome message. Here's how that would eb done:
```nasm
call clear_screen
mov si, welcomeMessage
call print_string
```

## Bootloader Expansion
### Why do it?
Simply put: 512 bytes is not very much.