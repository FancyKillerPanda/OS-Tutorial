---
layout: page
title: "A20 Line"
slug: "a20-line"
date: 2021-07-16 15:28:11 +1000
---

In this chapter, we'll look at an annoying quirk of the past and try to deal with it. Ugh? Yay? I'm not really sure to be honest.

## What is it?
The A20 line is the physical representation of the 21st bit of a memory access. Due to some peculiarity with the way some old computers had to work, this line had to be disabled by default. Read more [here](https://wiki.osdev.org/A20_Line).

If it's not enabled, some memory accesses (above the 1 MiB mark) will be incorrectly handled (for a proper example, see [here](https://forum.osdev.org/viewtopic.php?f=8&t=32115)).

The thing is, different hardware enabled the A20 line in different ways (I know, it sucks). So our code needs to do the same, or we might break on some other hardware.

## A Skeleton of Code
I'm going to create a new file for the A20 line code, since there's quite a lot of it. The way it's gonna work is we'll check if the A20 line is enabled, if it is then we're done, if it's not then we do another method of enabling it. Then we check if it's enabled again (because the method might not have worked), and so on.

We'll print out a string as well for when we succeed/fail to enable the A20 line. Here's `a20Utility-inl.asm`, with function stubs for the ways that we'll try enabling.

```nasm
bits 16

%macro finish_if_a20_enabled 0
	call check_a20
	cmp ax, 0
	jne .success
%endmacro

; void try_enable_a20()
try_enable_a20:
	.try:
		finish_if_a20_enabled
		call try_set_a20_bios
		finish_if_a20_enabled
		call try_set_a20_keyboard
		finish_if_a20_enabled
		call try_set_a20_fast
		finish_if_a20_enabled

	.fail:
		mov si, a20FailedMessage
		call print_string
		call reboot

	.success:
		mov si, a20SuccessMessage
		call print_string
		ret

; void try_set_a20_bios()
try_set_a20_bios:
	ret

; void try_set_a20_keyboard()
try_set_a20_keyboard:
	ret

; void try_set_a20_fast()
try_set_a20_fast:
	ret

; void check_a20()
check_a20:
	ret

a20SuccessMessage: db "Info: Enabled A20 line!", CR, LF, 0
a20FailedMessage: db "Error: Failed to enable A20 line!", CR, LF, 0
```

The only complex problem of this block of code is the macro. Wherever we have `finish_if_a20_enabled` will be replaced with the code inside the macro. You can now see that the `jne .success` (jump to `.success` if `ax` is not-equal `0`) will jump to the `.success` label in the `try_enable_a20` function.

We'll also need to include this file in our main `bootloader.asm` file, so let's do that. We'll place it after the first sector (in the expanded region), since that area is not limited in space.

```nasm
%include "a20Utility-inl.asm"
```
