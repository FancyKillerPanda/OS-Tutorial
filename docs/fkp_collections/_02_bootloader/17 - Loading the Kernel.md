---
layout: page
title: "Loading the Kernel"
slug: "loading-the-kernel"
---

It's time for us to load up the kernel!

## Background
I am going to load our kernel up at the 1 MiB mark, as it can be useful later on to not have the kernel below that. This, however, poses a major issue. Namely that we can only access the first megabyte of memory in Real Mode. Ok... so why not switch to Protected Mode? Well, we need BIOS interrupts in order to read data from disk, and BIOS interrupts are only available in Real Mode. See the connundrum?

The solution? Read a little bit of data in Real Mode, switch into Protected Mode to copy it over the 1 MiB mark. Switch back to Real Mode to read some more data. Rinse. Repeat.

***Yikes***

Let's do it!

## The Code
### Setup
Let's create a new file, `kernelLoadUtility-inl.asm`, starting it off with code I'm sure you're all too familiar with at this point. We'll define a constant for where the kernel will be loaded to, it's equal to the 1 MiB mark. Define the string somewhere.

```nasm
bits 16

KERNEL_FLAT_ADDRESS: equ 0x00100000

; void load_kernel()
load_kernel:
	.setup:
		mov si, loadingKernelMessage
		call print_string

		tempBufferSegment: equ 0x0200
		maxSectorsPerRead: equ 32
```

The final two lines there also define constants, the segment of the temporary buffer and the maximum number of sectors we'll read in one go. We'll have the temporary buffer ranging from `0x2000` - `0x6000`, as 32 sectors is `0x4000` bytes (16 kiB).

### Number of Sectors
We need to calculate how many sectors we should read. If there is more than 32 sectors left to read in the kernel, we should only read 32. If there's less, we want to read the amount that's left, not 32 sectors.

Let's define a couple variables that will help us keep track of how many sectors we've already read and how many we're going to do in the next read.

```nasm
sectorsAlreadyRead: dw 0
numberOfSectorsToReadNext: dw 0
```

We can then calculate the number of sectors like so:

```nasm
.calculate_number_of_sectors:
	mov dx, word [kernelNumberOfSectors]
	sub dx, word [sectorsAlreadyRead]
	cmp dx, maxSectorsPerRead
	jle .do_read
	mov dx, maxSectorsPerRead

.do_read:
	mov [numberOfSectorsToReadNext], dx
```

As you can see, if the number of sectors left to read is less than or equal to the max we jump straight to the `.do_read:` label, otherwise we reset it down to 32.

## Reading
Alright, we can reuse our `read_disk` function from earlier. For that, we need to set `es:bx` to point to the destination (in our case `0x2000`, or `0x0200:0x0000`) and have `cx` equal to the starting sector to read. `ax` should be set to the number of sectors to read. All of this is fairly simple, it can be done like so:

```nasm
mov dx, tempBufferSegment
mov es, dx
xor bx, bx

mov cx, word [kernelStartSector]
add cx, word [sectorsAlreadyRead]
mov ax, word [numberOfSectorsToReadNext]
call read_disk
```

## Copying to Above 1 MiB
Now that we're ready to copy over the 1 MiB mark, let's enable Protected Mode to allow us to access that area of memory.

```nasm
.copy_to_real_location:
	enable_protected_mode
```

We're going to be using the `movsd` instruction to "move string dword". This instruction moves a single dword (4 bytes) of data from the location `ds:esi` to the location at `es:edi`. Since our `ds` and `es` segment registers are already set (we don't need to change them), all we need to do is set `esi` to `0x2000` (where our temporary buffer is) and set `edi` to `0x00100000`. Well, not *exactly* `0x00100000`, since we also need to offset by how much we've already read in to there.

```nasm
; Source location
mov esi, tempBufferSegment * 0x10

; Destination location
movzx eax, word [sectorsAlreadyRead]
mov ecx, 512
mul ecx
mov edi, KERNEL_FLAT_ADDRESS
add edi, eax
```

As you can see from the code, to calculate the destination location we first need to calculate (in bytes) how much we've already read. This is simply the number of sectors multiplied by 512, which we add to `KERNEL_FLAT_ADDRESS` (which is `0x00100000`) to get the final location.

Now, if we just did a single `movsd` instruction we would only copy 4 bytes of data. *That's not nearly enough!* We will prefix the instruction with `rep`, which will tell the CPU to execute it as many times as `ecx` says. So let's calculate what `ecx` should be, shall we?

```nasm
mov eax, 128
movzx ecx, word [numberOfSectorsToReadNext]
mul ecx
mov ecx, eax
```

The number of dwords we are moving is simply the number of bytes we're moving divided by 4. We can't actually use the `div` instruction on `ecx` (since the `div` instruction has specific registers it uses), so we'll just recalculate `(512 / 4) * number of sectors`.

That's it! All that's left to do is tell the CPU to copy those bytes, and then disable Protected Mode so we can do it all again.

```nasm
rep movsd
enable_real_mode
```

## (Maybe) Doing It All Again
Alright, we now just need to update the number of sectors we've already read (since we can't directly write to a variable address, we'll load it in `eax` and then write it back) and jump back if we need to. We simply compare the number of sectors already read to the total number of kernel sectors, if they're the same we know we're done (and the `jl` won't occur).

```nasm
.read_again_or_finish:
	mov ax, word [sectorsAlreadyRead]
	add ax, word [numberOfSectorsToReadNext]
	mov word [sectorsAlreadyRead], ax

	cmp ax, word [kernelNumberOfSectors]
	jl .calculate_number_of_sectors

.done:
	mov si, loadedKernelMessage
	call print_string
	ret
```

We print out a nice little string to say we've loaded the kernel (you can define this somewhere).

## Up, Up, and Away
And now it's time to make the jump! In our `expanded_main`, let's call this function we just wrote. We'll also enable Protected Mode one last time, and then make our jump to `0x00100000`.

```nasm
call load_kernel
enable_protected_mode

jmp KERNEL_FLAT_ADDRESS
```

## Final Thoughts
**Well done!!!** If all has gone to plan, you should see a bunch of messages telling you that it's entering Protected/Real Mode again, and then a nice little one saying it's loaded the kernel. You should also see a little blue/white `Hello, world!` message being printed at the top of the screen (from the kernel!). If that's not what you get, have a look at the code again to make sure you've done everything correctly.

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/0dcecac61149ce2cd74c752059c85aae3dbbc3aa).
