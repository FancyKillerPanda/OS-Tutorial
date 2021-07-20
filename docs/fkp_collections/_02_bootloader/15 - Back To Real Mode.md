---
layout: page
title: "Back To Real Mode"
slug: "back-to-real-mode"
---

In the last chapter, we looked at what Protected Mode is and how we can enable it. This chapter will have very similar code, except we'll be looking at moving back into Real Mode from Protected Mode.

## Enabling Real Mode
### Setup
Once again we're going to define a macro and pause interrupts, just like we did last chapter.

```nasm
%macro enable_real_mode 0
	%%.setup:
		cli
```

### Jumping to 16-Bit Protected Mode
Before we can move back to Real Mode, we need to move into 16-bit mode (while still in Protected Mode). We will do this by using the 16-bit GDT selectors that we defined earlier. Like before, we need to clear the prefetch queue (so the CPU doesn't use its cache and continue executing 32-bit code), and set up the segments.

```nasm
	jmp gdtCode16Offset:%%.switch_to_16_bit_gdt
	nop
	nop

%%.switch_to_16_bit_gdt:
	bits 16
	
	mov ax, gdtData16Offset
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
```

### Disabling Protected Mode
When we enabled Protected Mode, we simply toggled the lowest bit on. Now, we're going to toggle that bit off in the same way. We'll also toggle the very highest bit off, as this bit tells the CPU that we have paging enabled (it shouldn't be on, this is just precautionary). The hex value `0x7ffffffe` represents a 32-bit number with every bit except the first and last set to 1.

```nasm
%%.disable_protected_mode:
	mov eax, cr0
	and eax, 0x7ffffffe
	mov cr0, eax
```

### Setting Up Segments
Now that we're in Real Mode again, let's set up our segments. If you take a look at the very start of `bootloader.asm`, you'll see we set all our segments to `0x00`. We're going to do the same here, so all data that could be accessed then can be accessed now. And as always, we need to make sure the CPU doesn't execute anything from the prefetch queue.

```nasm
	jmp 0x00:%%.reset_gdt_selector
	nop
	nop

%%.reset_gdt_selector:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov sp, word [bootloaderStackPointer]
```

You can see that we also load the stack pointer back to what it was before we enabled Protected Mode (we saved the stack pointer into a variable in the previous macro).

### Cleanup
To cleanup, let's load the Real Mode IDT structure that we defined a few chapters ago. This simply points the CPU to location `0x00` when it looks for interrupts, which is where the default BIOS ones are. After that, we can re-enable interrupts (`sti`) and print out a little message to show we're back in Real Mode.

```nasm
	%%.load_real_mode_idt:
		lidt [idtEntryRealMode]

	%%.cleanup:
		sti
		mov si, enableRealModeMessage
		call print_string
%endmacro
```

Of course we need to define the string `enableRealModeMessage`, do that where you defined the Protected Mode string.

## Final Thoughts
That's it, we're back in Real Mode! To test out everything works, you can repeatedly use the two macros we made. Something like this:

```nasm
enable_protected_mode
enable_real_mode
enable_protected_mode
enable_real_mode
enable_protected_mode
```

Should output something like this:
![QEMU Output]({{ site.baseurl }}{% link /assets/02-15 (Back To Real Mode) Output.png %})

We'll look at loading the kernel in the next chapter, hang tight!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/e0254caf549e9d50bfb770a79d963a8783e5dc36).
