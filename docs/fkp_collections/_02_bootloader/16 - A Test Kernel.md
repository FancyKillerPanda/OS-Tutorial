---
layout: page
title: "A Test Kernel"
slug: "a-test-kernel"
---

*It's finally time!* We're going to create a test kernel and build system in this chapter, so that we can finally begin our move from assembly to C++ (unfortunately, we're not *quite* done with assembly yet).

## The Kernel Itself
Our `kmain` function needs to be defined with `extern "C"` linkage so that the compiler does not mangle its signature. We need this because we're going to be calling `kmain` from assembly.

I'll explain what this code actually does in a future chapter (when we start properly printing strings from C++ code), for now all you need to know is that it'll output `"Hello, world!"`. We'll put this in a new file: `kernel/kernel.cpp`.

```cpp
extern "C" void kmain()
{
	u8* address = (u8*) 0xb8000;
	const char* string = "Hello, world!";
	u16 stringSize = 13;

	for (u16 i = 0; i < stringSize; i++)
	{
		*address = (u8) string[i];
		address += 1;
		*address = (u8) 0x9f;
		address += 1;
	}

	while (true);
}
```

## The Entry Point
When we jump to the kernel's starting address, we need some code to be executed straight away that will call `kmain`. That's what this entry point is. Let's create an `entryPoint.asm` file.

```nasm
bits 32

extern kmain

section .entry

; void start()
global start
start:
```

Here you see we mark `kmain` as `extern`, this allows us to call it from this file. We also mark the `start` label as `global`, which will allow us to reference it in other parts of our build system later. The line `section .entry` tells the linker that this section of code (everything down from there until another `section` directive or the end of file) is in the section named `.entry`. This will come in handy later.

All that needs to happen in `start:` is setting the stack pointer (we'll define 16 kiB for our stack, as you can see at the bottom) and then calling `kmain`. We have a loop to hang us if `kmain` returns, but we'll generally have a `while (true);` at the end of `kmain` so that shouldn't happen.

```nasm
	mov esp, kernelStackStart
	call kmain

	.hang:
		cli
		hlt
		jmp .hang

align 16
kernelStackEnd:
	times 16384 db 0
kernelStackStart:
```

## The Linker Script
The linker script (or just link script) is a file that gives the linker information about how to link your program. This includes things like the entry point (by default it's `main`), where different sections go, etc.

Let's define the entry point as `start` (this is why we needed to mark it as `global` earlier). Here's the start of `linkScript.ld`:

```ld
ENTRY(start)
```

Alright, next up we need to define where our sections go. Assigning to the dot tells the linker what address it should be at. That might seem confusing, but in the example below it just means we want to start everything at the address `0x00100000` (the 1 MiB mark). This is where we will actually load up our kernel to in future (making the place where the linker *thinks* we are the same as where we actually are).

```ld
SECTIONS
{
	/* The kernel begins at the 1MB physical mark. */
	. = 0x00100000;
```

Next we define the `.text` output section. We align it to 4 kiB, and also tell it that it should be at the current location. Inside this output section (`.text`), we put everything in the `.entry` input section and in the `.text` input section. Yes, there's an input section named `.text` and an output section with the same name.

Note that the very first item is the `.entry` input section, which means that it will be put at the `0x00100000` mark. This is very important, as later on when we `jmp` to this location, we want the code in `.entry` to execute.

```ld
.text ALIGN(4k) : AT(.)
{
	*(.entry)
	*(.text .text.*)
}
```

Alright, I hope that made sense. We'll do similar things for the `.rodata` (for read-only data), `.data` (for data (*duh*)), and `.bss` (for uninitialised data) sections. These are not sections that we define manually, the compiler will do it by itself.

```ld
	.rodata ALIGN(4k) : AT(.)
	{
		*(.rodata .rodata.*)
	}

	.data ALIGN(4k) : AT(.)
	{
		*(.data .data.*)
	}

	/* Not actually *in* the image. */
	.bss ALIGN(4k) : AT(.)
	{
		*(COMMON)
		*(.bss .bss.*)
	}
}
```

That's it for the link script, we'll now move on to the build files.

## Modifying Build Scripts
