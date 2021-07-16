---
layout: page
title: "The genVDisk Utility"
slug: "genVDisk-utility"
date: 2021-07-11 10:09:17 +1000
---

## What is `genVDisk`?
The tool `genVDisk` is one that I created while developing PandaOS. It takes raw binary files for the bootloader and kernel and combines them together, and it also writes out magic values in the bootloader.

The magic values tell the bootloader the size of itself and the size of the kernel, both in sectors, so that the bootloader knows how much data to read from disk (when expanding itself and when loading the kernel).

While you can write a tool like this yourself if you'd like, that will not be covered in this tutorial.

## Where can I get it?
The `genVDisk` tool is open-source as part of the PandaOS repository, so you can [build it](https://github.com/FancyKillerPanda/PandaOS/blob/master/tools/scripts/buildGenVDisk.sh) from [source](https://github.com/FancyKillerPanda/PandaOS/tree/master/src/genVDisk) if you'd like. Alternatively, you can download a copy of it (built for Linux) from [here]({{ site.baseurl }}{% link /assets/genVDisk %}).

## How do I use it?
The `genVDisk` tool accepts a few different arguments.
```bash
$ genVDisk --help
Usage: genVDisk [options]
Options:
        [--help              ]: Displays this help message.
        [--output <path>     ]: The name of the output file.
        [--floppy            ]: Sets the disk type to be "Floppy Disk".
        [--bootloader <path> ]: Specifies the bootloader file.
        [--kernel <path>     ]: Specifies the kernel file.
```

The four non-help arguments are all mandatory, so we will have to create an empty `kernel.bin` file to pass in for the time being (until we actually have a kernel going). Under the call to `nasm` in `build.sh`, add:
```bash
touch kernel.bin # This will create an empty kernel binary
../tools/genVDisk --output "OS-Tutorial.img" --floppy \
				  --bootloader bootloader.bin --kernel kernel.bin
```

You will also need to change the `qemu-system-i386` call to use `OS-Tutorial.img` as its file, rather than `bootloader.bin`.

## The Magic Numbers
Now it's time for us to read the magic numbers in the bootloader file, and save them for later. There are 6 bytes of magic numbers, which are written immediately before the `0xaa55` bytes. We can add labels to those bytes by changing our current end-of-first-sector code to:
```nasm
times 504 - ($ - $$) db 0

bootloaderNumberOfExtraSectors: dw 0
kernelStartSector: dw 0
kernelNumberOfSectors: dw 0

dw 0xaa55
```

As you can see, this simply reduces the number of padding bytes we insert, then gives the next three 2-byte pairs a name, so that we can point to them later. If all goes well, you should still have the same output as before when running your program!

## Final Thoughts
This chapter was a set up for the next one, where we will be implementing disk reading to expand the bootloader. See you there!

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/11e031ba612a21d6a7d405a0c2752c2472664c00).
