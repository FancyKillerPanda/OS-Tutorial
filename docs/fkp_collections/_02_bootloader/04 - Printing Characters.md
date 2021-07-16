---
layout: page
title: "Printing Characters"
slug: "printing-characters"
date: 2021-07-10 15:09:28 +1000
---

What use is a bootloader if it can't even output strings to the screen? In this chapter, we'll take a look at using BIOS interrupts to print characters to the screen.

## BIOS Interrupts
To get the BIOS to do things for us, we can make use of "BIOS interrupts". These are special functions that are implemented by the BIOS, we simply tell it what we want to call (and pass it parameters through registers) and it'll execute it for us. Sweet!

### For Printing a Character
To print out a character, we will be using BIOS interrupt `0x10`. Looking at the [documentation on Wikipedia](https://en.wikipedia.org/wiki/INT_10H), we see:

```
ah = 0x0e
al = Character
bh = Page Number
bl = Color (only in graphic mode)	
```

We won't be needing the colour here, and the page number will just be 0 (the first page). So that just leaves us with data for `ah` and `al`. Let's do it!

## The Code
Here's where we left off last time:

```nasm
org 0x7c00

start:
	jmp start

end:
	times 510 - ($ - $$) db 0
	dw 0xaa55
```

Firstly, let's change `jmp start` to `jmp $`. Recall that `$` just means "the current location", this will create an infinite loop just like before, but will also let us insert code between `start` and the loop.

```nasm
mov ah, 0x0e
mov al, 'A'
xor bx, bx		; Sets both page (bh) and colour (bl) to 0
int 0x10
```

This code is fairly straightforward, we move values we want into the registers (in this case printing the letter "A"), and then invoke the interrupt using `int 0x10`.

Running this code should give us a little letter A on the screen, then an infinite hang. Wasn't that easy?

## Final Thoughts
That's gonna be it for this chapter, but you should experiment with the code to see if you can create something more complex. In the next chapter, we'll be going over writing a function to print an entire string, so see if you can do that without me first!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/bce5051461fd47aab13f43e530ed44d6c539ca88).
