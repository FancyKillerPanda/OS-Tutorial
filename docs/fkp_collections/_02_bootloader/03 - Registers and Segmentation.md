---
layout: page
title:  "Registers and Segmentation"
slug:  "registers-and-segmentation"
date:   2021-07-10 13:56:22 +1000
---

In this chapter, we will go over the registers the CPU uses to manipulate data, as well as the segmentation system that is used in Real Mode.

## Registers
Before we can move forward with programming in assembly, we must talk a bit about the way we work with data in assembly. The data that the CPU is currently operating on is stored in "registers". In 16-bit Real Mode (which is the default when the BIOS hands control to your bootloader), registers are each 16-bits in width (2 bytes). In 32-bit Protected Mode (which we'll switch to later, don't worry too much about this right now), the registers have an `e` prefix (for "extended") and are 32-bits (4 bytes) wide.

Here is a diagram of the `eax` register:
```
|               eax               |
                  |       ax      |
                  |  ah  | |  al  |
00000000 00000000 00000000 00000000
```
As you can see, the same data can be accessed through multiple register names (`al` refers to the lower byte of `ax`, which is in turn the lower half of `eax`). Here is a table of all the registers that you can access:

| Name | 32-bit | 16-bit | 8-bit | Usage |
|--------|--------|--------|--------|--------|
| Accumulator | eax | ax | ah, al | General purpose |
| Base | ebx | bx | bh, bl | General purpose |
| Counter | ecx | cx | ch, cl | General purporse, often used for keeping count |
| Data | edx | dx | dh, dl | General purpose |
| Source Index | esi | si | - | Used to point at source data |
| Destination Index | edi | di | - | Used to point at destination data |
| Base Pointer | ebp | bp | - | Points at the base of the stack frame |
| Stack Pointer | esp | sp | - | Points at the top of the stack |

| Name | 16-bit | Usage |
|--------|--------|--------|
| Code Segment | cs | Segment of code |
| Data Segment | ds | Segment of your data |
| Extra Segments | es, gs, fs | Usable for other segmentation |
| Stack Segment | ss | Segment of the stack |

## Segmentation
You may have noticed a few extra 16-bit registers above, called segment registers (`cs, `ds, `es`, `fs`, `gs`, `ss`). These exist due to the way memory is handled in 16-bit Real Mode.

You see, in order to access a full 1 MiB of memory using 16-bit registers, some trickery must be done (because a 16-bit register on its own can have a max value of `0xffff`, which would be around the 64 kiB mark of memory, not nearly enough for 1 MiB). The solution that was implemented all those years ago? Have a "segment register" that's multiplied by 16 before adding the actual value on. Confused? Let's look at some examples.

When the value of the segment register (we'll use `ds` in this example, because it's the default) is 0, nothing changes.

`ds = 0x0000`, `si = 0x7c00`, therefore `ds:si = (0x00 * 0x10) + 0x7c00 = 0x7c00`

However if we increase `ds`, we can access different areas of memory.

`ds = 0x0010`, si = `0x7c00`, therefore `ds:si = (0x0010 * 0x10) + 0x7c00 = 0x7d00`

Note that we can access the same area of memory, using different combinations of segment and offset. For example, these both point to `0x7c00`:
```
ds = 0x0000, si = 0x7c00
ds = 0x07c0, si = 0x0000
```

## In Code
Let's say we want to access a value at the location `0x7c00`. Here are two ways of doing that, analyse and compare them yourself (note: we can't move values directly into segment registers, so we will go via `ax` here). Can you understand what is happening? Why do we use `dword` there?

```nasm
mov ax, 0x07c0
mov ds, ax
mov si, 0x0000	; More commonly seen as: xor si, si
mov eax, dword [ds:si]
```

```nasm
mov ax, 0x0000
mov ds, ax
mov si, 0x7c00
mov eax, dword [ds:si]
```
As was mentioned earlier, the default segment is `ds`. This means that `ds:` can often be omitted. The code above may look something like the code above in the real world.

```nasm
xor ax, ax
mov ds, ax
mov si, 0x7c00
mov eax, dword [si]
```

## Final Thoughts
That's it for this chapter! In the next one, we'll look at how we can use our knowledge of assembly programming to get some characters printing to the screen.
