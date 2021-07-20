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
	unsigned char* address = (unsigned char*) 0xb8000;
	const char* string = "Hello, world!";
	unsigned short stringSize = 13;

	for (unsigned short i = 0; i < stringSize; i++)
	{
		*address = (unsigned char) string[i];
		address += 1;
		*address = (unsigned char) 0x9f;
		address += 1;
	}

	while (true);
}
```

## Unity Build
This step is pretty optional, though I do recommend it. A unity build is where a single C++ file is compiled, a file which `#include`s every other C++ file (not the headers, I mean the actual `.cpp` ones). The major advantage of this style of build is that header files are only parsed a single time, rather than a single time for each C++ file. Additionally, since the compiler is only invoked a single time, it can improve efficiency by reducing overhead.

Let's define `unityBuild.cpp`, which will currently only have one include (this will grow over time).

```cpp
#include "kernel.cpp"
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
.text ALIGN(4k) : AT(ADDR(.text))
{
	*(.entry)
	*(.text .text.*)
}
```

Alright, I hope that made sense. We'll do similar things for the `.rodata` (for read-only data), `.data` (for data (*duh*)), and `.bss` (for uninitialised data) sections. These are not sections that we define manually, the compiler will do it by itself.

```ld
	.rodata ALIGN(4k) : AT(ADDR(.rodata))
	{
		*(.rodata .rodata.*)
	}

	.data ALIGN(4k) : AT(ADDR(.data))
	{
		*(.data .data.*)
	}

	/* Not actually *in* the image. */
	.bss ALIGN(4k) : AT(ADDR(.bss))
	{
		*(COMMON)
		*(.bss .bss.*)
	}
}
```

That's it for the link script, we'll now move on to the build files.

## Modifying Build Scripts
### Flags
In our `build.sh` file, let's add a few variables to contain flags to pass to the compiler. 

```bash
kernelCompileFlags="-ffreestanding -nostdinc -nostdinc++ \
					-Wall -Wextra \
					-o kernel.bin -target i386-pc-none-elf \
					-I ../src/kernel/"
kernelLinkFlags="-nostdlib -Wl,--oformat=binary,-T../src/kernel/linkScript.ld"
kernelFiles="../src/kernel/unityBuild.cpp"
```

Ok, let's go through the flags.

| Flag | Use |
| ======== | ======== |
| `-ffreestanding` | Directs the compiler to not assume a standard environment where standard functions have their usual definitions. |
| `-nostdinc` and `-nostdinc++` | Disables standard include directories for C and C++ headers. |
| `-Wall` and `-Wextra` | Turns on warnings. |
| `-o kernel.bin` | We are outputting to a file called `kernel.bin`. Note you can now remove `touch kernel.bin` from the build file, since we're actually creating it properly. |
| `-target i386-pc-none-elf` | This is called a target triple. It specifies what architecture and format we want to build to. In this case, an x86 output in the format of ELF (Executable and Linkable Format). This format is common on Linux, though windows uses a different format (Portable Executable). |
| `-I ../src/kernel` | We add an additional include directory to our main kernel directory. |
| `-nostdlib` | Tells the compiler not to use the regular standard library. |
| `-Wl,` | Will pass a comma-separated set of flags directly to the linker. |
| `--oformat=binary` | Tells the linker we want a binary file output. |
| `-T../src/kernel/linkScript.ld` | Gives a path to the linker script we defined. |


### Calling NASM
We need to call NASM on the entry point file we just created. This can be done like so:

```bash
nasm -felf32 ../src/kernel/entryPoint.asm -o kernelEntryPoint.o || exit 1
```

This tells NASM to output a `kernelEntryPoint.o` file, in a 32-bit ELF format.

### Calling Clang
Finally, we'll call Clang to compile our program. This is quite a simple command:

```bash
clang++ $kernelCompileFlags $kernelLinkFlags $kernelFiles || exit 1
```

## Final Thoughts
If you run this now... nothing much should have changed. We'll be able to test that everything worked in a future chapter when we've loaded the kernel, but for now you'll just have to trust in it. The genVDisk utility should now be saying that it output a number of sectors for the kernel, so make sure that's happening!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/611261d26187867eabdb9b3328231a83ad111fa8).
