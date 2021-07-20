---
layout: page
title: "Printing Strings"
slug: "printing-strings"
---

Here we go, printing entire strings! If you haven't already had a go at it, I'd strongly recommend doing so.

## Functions
Coming from a language such as C++, you'll likely be very familiar with functions. In assembly, labels can act as functions. You can use the instruction `call`, along with an address (labels resolve to addresses), to make a jump to that place in the code. When the CPU encounters a `ret` instruction, it will return back to where it was earlier. Simple?

## A `print_string` Function
So, what do we need to do to print a string? The basic steps can be described as follows:
1. Get the next character
2. Check if the character is 0, indicating a NULL terminator. If it is, we're done. Otherwise, continue on.
3. Print the character
4. Go back to 1.

That seems fairly straightforward, let's see if we can implement it in code.

```nasm
; void print_string(ds:si string)
print_string:
	.print_char:
		; Gets a character and compares it with NULL
		mov al, [ds:si]
		cmp al, 0
		je .done

		; Calls the interrupt to print a character
		mov ah, 0x0e
		xor bx, bx
		int 0x10

		; Move to the next character
		inc si
		jmp .print_char

	.done:
		ret
```

Here you can see that we will pass a pointer to the string to print in `ds:si` (as indicated by the comment above the function).

We move a single character into the `al` register, and compare it with 0. The `cmp` instruction compares two values, in this case `al` and `0`. The next instruction, `je`, looks at the most recent `cmp` and "Jumps if Equal". There are other instructions that could be used as well, such as `jl` ("Jump if Less") or `jne` ("Jump if Not Equal").

The code to call the interrupt is extremely similar to the code we had last time. After the interrupt is called, we increment `si` (to move the pointer to the next character) and jump back.

## Using the Function
We're not quite done yet, we still need to define a string to print out and we need to call the function. To define a string, we can use the `db` instruction, along with a string literal. Note that this string literal doesn't terminate itself with 0, so we have to do that ourselves.

```nasm
stringToPrint: db "Hello, world!", 0
```

To use the function, lets put this code after the `start` label (you can get rid of the single character print test we did in the previous chapter). Remember, we can't directly move values into segment registers, we must go via another general-purpose register (in this case, `ax`).
```nasm
xor ax, ax
mov ds, ax

mov si, stringToPrint
call print_string
```

The first two lines simply set the `ds` segment to 0, so that it does not affect the address at all. We move the pointer of `stringToPrint` into `si`, and then call the function.

That's it! Running this in QEMU now should output your string.

## Practice
Some things to try out and play around with:
1. Can you get more than one string printing?
2. Can you print a second string on a new line?

## Final Thoughts
That's all we'll cover in this chapter, see you next time!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/510d03dfe4d9938a1d052bf4dbfa42c0dca930f4).
