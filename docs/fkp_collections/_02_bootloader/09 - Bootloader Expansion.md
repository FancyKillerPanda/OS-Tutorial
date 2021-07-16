---
layout: page
title: "Bootloader Expansion"
slug: "bootloader-expansion"
date: 2021-07-16 14:13:55 +1000
---

In this chapter we will *finally* get the bootloader expanding! We will look at writing a function to read from the disk, and then we'll call that function on the rest of our bootloader to expand it.

## The `read_disk` Function
First things first, let's start off by writing out a signature for the function.

```nasm
; void read_disk(cx sector, al number-to-read, es:bx into)
read_disk:
```

Here we take three (really four) parameters, the sector number (i.e. LBA) to start reading from (`cx`), how many sectors we want to read (`al`), and where we want to put the data we read (as a segment/offset pair `es:bx`).

We need to calculate the CHS from the initial sector LBA we're given; we can do this using the function we created in the last chapter. However, we'll also `push` and `pop` `ax` and `bx`, since the function uses those registers and we'd like to keep the values they currently have.

```
.read:
	push ax
	push bx
	call calculate_chs
	pop bx
	pop ax
```

Simple! That leaves us with the cylinder and sector values in `cx`, and the value for the head in `dh`. Luckily for us (*this may have been planned :)* ), this is the exact format the BIOS wants for the call to its interrupt. *How convenient!* All we need to do now is fill in the value for `ah` (to tell the BIOS which function we are calling), and `dl` (to tell the BIOS what the boot drive number is). Recall how we stored the `bootDriveNumber` in a previous chapter, this is why!

```nasm
mov dl, [bootDriveNumber]
mov ah, 0x02
int 0x13
```

Easy peasy! Let's jump to an error handling part if the function failed (the carry flag will be set if the interrupt fails, `jc` will "jump if carry flag"), otherwise we can return like normal.

```nasm
	jc .read_failed
	ret

.read_failed:
	mov si, diskErrorMessage
	call print_string
	call reboot
```

All that happens is that we print out an error message, and then reboot. For that, we'll need to define the error message, here's my definition:

```nasm
diskErrorMessage: db "Error: Failed to read disk!", CR, LF, 0
```

## Using the Function for Expansion
In the `.expand_bootloader` part of our `main` function (after we print out our message), let's add some code to call the `read_disk` function. All we need to do is set a destination and give it a starting sector and length (which we get from the `genVDisk` utility's magic values).

```nasm
; Destination
mov ax, 0x07e0
mov es, ax
xor bx, bx

; Start sector and length
mov cl, 1
mov al, [bootloaderNumberOfExtraSectors]

call read_disk
```

You can see that the destination here is set to `0x7e00` (as the segment is `0x07e0` and the offset is `0x0000`). Conveniently, this is exactly 512 bytes (one sector) after where we are currently loaded (`0x7c00`). What we're doing is simply loading the remaining sectors of the bootloader from disk to a location directly after where we are now, so we can pretend that the entire bootloader was loaded by the BIOS (rather than just a single sector).

If you run this now, you probably won't see anything interesting. Let's output a message in the expanded part of our bootloader to make sure it works.

```nasm
expanded_main:
	mov si, expandedMessage
	call print_string

	jmp $

expandedMessage: db "Info: Bootloader expansion successful!", CR, LF, 0
```

This can all be done after the initial sector (where we define `0xaa55`), if our expansion works properly you should see the `expandedMessage` get printed out!

## Final Thoughts
Well done! Now that we've got an expanding bootloader out of the way, we can work on more important things (such as getting the kernel loaded) without worrying that we're going to run out of the initial 512 byte space we were given.

In the next chapter I'll look at how we can debug our code with Bochs, as that will be extremely useful later on. Hang tight!

![Output]({{ site.baseurl }}{% link /assets/02-09 (Expanding Bootloader) Output.png %})

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/9e05af876d959ff4841d40481fd6f6449d90046f).
