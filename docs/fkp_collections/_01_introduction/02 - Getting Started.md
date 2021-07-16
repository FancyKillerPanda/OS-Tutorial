---
layout: page
title: "Getting Started"
slug: "getting-started"
date: 2021-07-10 10:27:04 +1000
---

## Development Environment
### WSL2
For this project, I'm using the Windows Subsystem for Linux 2, which allows Windows users to run a Linux kernel through Windows (in my case, Ubuntu 20.04). Although you *can* use plain-old Windows for this (all the tools should be available for Windows as well), I've found a large increase in quality-of-life using WSL2.

See the [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for more information on setup.

## Build Tools
### Clang
Clang is a compiler for C/C++ built upon LLVM, a large set of toolchains and backends for compilers. GCC is a popular choice in the programming industry, but OSdev requires cross-compilation, which I have found to be easier with Clang. With Clang, you simply specify the target architecture and all is well, whereas you would need to build a specific version of GCC by yourself to cross-compile. Not impossible... but I like making my life easy!

[Downloads page](https://releases.llvm.org/download.html), or use your package manager.

```bash
$ clang --version
> 10.0.1
```

### NASM
The Netwide Assembler (NASM) is one of the most popular assemblers for the x86 architecture. Its syntax is based on the Intel syntax, making it (IMO) much easier to read and follow than assemblers based on AT&T syntax. You can, of course, use an AT&T-based assembler, but you'll have to translate code from this guide into it.

[Downloads page](https://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D), or use your package manager.

```bash
$ nasm --version
> 2.14.02
```

## Debugging Tools
In order to run your Operating System, you'll need an emulator (you could run on real hardware too, but why make life difficult?). There are two different emulators we'll be using, QEMU and Bochs. We use multiple emulators as some code may work in one, but not the other; having multiple lets us iron out as many bugs as possible.

### QEMU
QEMU will be used as a general test area for our OS. Generally, I just use it to see if my project runs, not really much for debugging.

[Downloads page](https://www.qemu.org/download/), or use your package manager.

```bash
$ qemu-system-i386 --version
> 4.2.1
```

### Bochs
Bochs is the emulator that we will be mostly using for debugging, as it comes with great debugging functionality (breakpoints, stepping through code, inspecting registers, etc.). While you could get Bochs through WSL2 like the rest of the tools, I have always just used it through Windows. 

[Downloads page](https://sourceforge.net/projects/bochs/files/bochs/).

You should see two executables, `bochs.exe` and `bochsdbg.exe`. The debug one is the one that has debugging functionality packaged inside, the plain one is just a regular emulator.
