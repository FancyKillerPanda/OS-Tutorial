---
layout: page
title: "IDT"
slug: "idt"
date: 2021-07-18 10:44:49 +1000
---

The Interrupt Descriptor Table (IDT) is a table which tells the CPU where to look for interrupt routines (special functions that may be triggered by the CPU when different things happen). An example of an interrupt routine is the Keyboard Interrupt (handler index 1), which is called anytime a key is pressed.

For now, we're just going to have our IDT at `0x7100` (you'll notice that this is just after the GDT). There are 256 8-byte entries (2048 bytes total) in the table, but we'll fill our actual data in with zeroes for the moment (our kernel will define actual handlers and add in pointers to those).

## The Code
```nasm
; void describe_idt()
describe_idt:
	.setup:
		push es
		xor ax, ax
		mov es, ax
		mov di, [idtEntry.pointer]

	.describe:
		mov cx, 1024
		rep stosw

	.cleanup:
		pop es
		ret
```

This describe function simply sets `ax` to `0`, and moves `0x7100` into `es:di`. It uses the `stosw` instruction, which will "store a string word" from `ax` into `es:di`. The instruction also increments `di` by 2 bytes (1 word). The `rep` prefix tells the CPU to do the next instruction as many times as described in `cx`, which for our purposes is `1024`. This means we simply insert 2048 bytes of `0` into `es:di`.

You'll notice that a label `idtEntry.pointer` is referenced in the code above. We can define that as below:

```nasm
idtEntry:
	.size: dw 1024
	.pointer: dd 0x7100

idtEntryRealMode:
	.size: dw 1024
	.pointer: dd 0x0000
```

These labels are what we need to actually pass to the CPU when we load the IDT, it simply outlines the number of entries and a pointer to them. We have a second struct that we can use when returning to Real Mode (we'll get to this more later). We don't need to define anything for this, we simply point it to `0x0000` (which is where the BIOS interrupt routines are already stored).

## Calling It
In our `expanded_main`, we should call our `describe_idt` function. We won't actually *load* the IDT into the CPU just yet (we'll do this when moving into protected mode); we're just describing it so we can load it later easily.

```nasm
call describe_idt
```

## Final Thoughts
That's it for this one! It's a fairly short chapter, but the next one on GDTs will be somewhat longer. Hang tight!
