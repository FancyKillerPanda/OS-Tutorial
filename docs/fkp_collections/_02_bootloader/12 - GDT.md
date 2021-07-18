---
layout: page
title: "GDT"
slug: "gdt"
date: 2021-07-18 11:07:23 +1000
---

We've covered the Interrupt Descriptor Table, now it's time to describe a Global Descriptor Table (GDT). This is a similar table to the IDT, made up of 8-byte entries (though there are not nearly as many of them). When in Protected Mode, the GDT tells the CPU about the memory segments, and how they should be used (note that the way of segmentation of multiplying the segment by 16 doesn't happen in Protected Mode).

There are two main types of segments that we wil define, a "code-segment" and a "data-segment". A code segment contains executable permissions, so the CPU will have no issues executing code through it. A data segment does not, and so will be used for basically everything else. When we switch into Protected Mode, we'll set `cs` to the code segment descriptor, and all other segment registers to the data segment descriptor.

We will, however, need to define four separate descriptors, not two. This is because we need to have 32bit versions of each for Protected Mode, but we'll also need 16bit versions of each (for switching back from Protected Mode to Real Mode).

## Setup
Let's define an entry that we can pass to the CPU (like `idtEntry` from the last chapter), as well as the start of the function which will describe the table. 

```nasm
gdtEntry:
	.size: dw 40
	.pointer: dd 0x7000
	
; void describe_gdt()
describe_gdt:
	.setup:
		push es
		xor ax, ax
		mov es, ax
		mov di, [gdtEntry.pointer]
```

This simply sets `es:di` to `0x7000` (which you'll notice is just before the IDT), getting us ready to start describing.

## Descriptors - An Overview
Before we start describing the descriptors themselves, let's have a look at what each 8-byte entry consists of. It's a bit complex. Why is it complex? Legacy!

| Byte | Bits | Use |
|========|========|=========|
| 0 - 1 | 0 - 15 | Limit (bits 0 - 15) |
| 2 - 4 | 16 - 39 | Base (bits 0 - 23) |
| 5 | 40 - 47 | Access byte |
| 6 | 48 - 51 | Limit (bits 16 - 19) |
| 6 | 52 - 55 | Flags |
| 7 | 56 - 63 | Base (bits 24 - 31) |

Ok, let me explain that. The *limit* is a 20-bit value that tells the CPU what the maximum addressable area (this could be defined in pages or in bytes, we'll use bytes). The *base* is the location where this segment starts, which we'll always set to `0x00`. The *access byte* and *flags* define properties about the segment, such as if it has executable permissions or not.

## Defining Them

