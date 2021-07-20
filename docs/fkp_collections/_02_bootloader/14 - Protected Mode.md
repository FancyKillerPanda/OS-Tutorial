---
layout: page
title: "Protected Mode"
slug: "protected-mode"
---

## What is Protected Mode?
According to the [OSdev wiki](https://wiki.osdev.org/Protected_Mode), "Protected mode is the main operating mode of modern Intel processors (and clones) since the 80286 (16 bit)". It "enables the system to enforce strict memory and hardware I/O protection".

We'll be using Protected Mode as the main mode our OS kernel runs in (we'll enable it before jumping to the kernel). When the CPU boots up, it starts in 16-bit Real Mode. It is up to us to change that to either a 16-bit Protected Mode (we won't use this very much) or a 32-bit Protected Mode (which we'll use a lot).

There also exists Long Mode, which is the 64-bit companion to Protected Mode. Our OS will be focussing on 32-bit for now (though I've heard that in some areas 64-bit is even easier), so we won't be using Long Mode (yet).

## Enabling Protected Mode
Protected Mode is enabled by setting the least significant bit of the `cr0` register (the first "control register") to 1, but there are some things that we'll need to do before and after to ensure the CPU doesn't freak out on us.

### Setup
Let's create a macro for enabling protected mode (we can't use a normal function because we're messing with the stack and such, the function won't know where to return to). I'm putting this all in a new file I'll call `kernelLoadMacros-inl.asm`.

```nasm
%macro enable_protected_mode 0
	%%.setup:
		mov si, enableProtectedModeMessage
		call print_string
```

Here we define a macro which takes no parameters, and print out a string (you can define `enableProtectedModeMessage` somewhere).

We should also disable interrupts for the time being, we don't want the CPU to go do something else halfway through this.

```nasm
cli
```

Next, we're gonna load up the GDT and IDT. Remember how we defined them in previous chapters? Now we're just telling the CPU to use those tables. The instructions `lgdt` (load GDT) and `lidt` (load IDT) take the location of the structures we defined as a parameter.

```nasm
lgdt [gdtEntry]
lidt [idtEntry]
```

Finally, we should save the current stack pointer so that when we return to Real Mode, we can load it back and continue from where we were. 

```nasm
mov word [bootloaderStackPointer], sp
```

This also needs a definition for `bootloaderStackPointer`, put it in `bootloader.asm` (we don't want any data in this file, only macros). Since macros have to be defined before use (unlike normal labels), we need to `%include "kernelLoadMacros-inl.asm"` at the top of our `bootloader.asm`, not at the bottom like the other includes. 

### Enabling
Alright, it's time to enable Protected Mode. As I said earlier this is as simple as toggling the lowest bit of the `cr0` register on, but we're not allowed to modify it directly. So instead we read it into `eax` and toggle that, then write it back out. Like this:

```nasm
%%.enable:
	mov eax, cr0
	or eax, 1
	mov cr0, eax
```

### Setting Up Segments
Since we don't use actual segmentation in Protected Mode, our segment registers contain the offset to the GDT entry that we will be currently using. This means that the code segment `cs` needs to contain the offset of 32-bit code, and the data segments (all other segment registers) need to contain the offset of 32-bit data (from the GDT).

We can't actually set `cs` directly (the CPU won't let us), so we need to issue a `jmp` instruction with an argument in the form `segment:offset` (where `segment` will be put into `cs` and we'll move to the location `offset`).

```nasm
	jmp gdtCode32Offset:%%.setup_segments
	nop
	nop

%%.setup_segments:
```

The reason that I've put two `nop` instructions after the jump is that the CPU sometimes fetches the next instruction early (called a prefetch). We want to make sure it doesn't execute what's in the prefetch queue, since we'll be switching to 32-bit instructions in a moment.

We're going to use the `bits 32` instruction to tell NASM to compile the code to target a 32-bit CPU. You may have noticed that I'd put `bits 16` around earlier, this was to tell NASM that we wanted 16-bit output. Since we're putting `bits 32` in a macro, any time this macro is expanded NASM will output 32-bit code from then on. For this reason, I've put extra `bits 16` over the top of code I know should be 16-bit.

```nasm
bits 32

mov ax, gdtData32Offset
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov esp, 0x20000
```

Here you can see we put the offset of the 32-bit data GDT entry into all the other segment registers (note that segment registers are always 16 bits wide), and then set up the stack. The choice of `0x20000` for the Protected Mode stack was a bit arbitrary, I have simply chosen a location within usable memory.

That's all we need to do to enable Protected Mode. Let's tell NASM we're done:

```nasm
%endmacro
```

## Final Thoughts
Unfortunately, BIOS interrupts are not available when in Protected Mode. This means that we won't be able to use our `print_string` function while in here (when we get to the kernel (soon!) I'll show you how to output text). What you can do is set a breakpoint after the macro to make sure that we get to that point; if we don't go into a boot loop everything should be fine!

In the next chapter, we'll look at how we can create a macro to head back into Real Mode (we'll need to use both these macros when loading the kernel)!
