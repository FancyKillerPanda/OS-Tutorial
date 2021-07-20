---
layout: page
title: "Using Bochs"
slug: "using-bochs"
---

You are already able to use QEMU to run your OS, let's set up Bochs so you can debug it more easily.

## Editing Options
When you start up `bochsdbg.exe`, you should get a pop-up similar to this:
![Bochs Start Menu]({{ site.baseurl }}{% link /assets/Bochs Start Menu.png %})

You can leave most of it at the default, I'll go through what you need to change here.

### Display & Interface
In this category, you need to set `Display Library Options` to `gui_debug` (the default is `none`). This will allow you to use a proper GUI for debugging, rather than having to use the command line.

### Disk & Boot
Here is where everything about the booting process will be configured. The first page you'll be presented with is `Floppy Options`, you'll need to select `3.5" 2.88M` as the type of the first floppy drive. This means that we will emulate a 2880 kiB floppy drive, which is the same as what QEMU is emulating (by default). 

You should then pass it the path to your output `.img` file, and set the `Type of floppy media` to `2.88M`. The status of this drive should be `inserted`, so that we can boot from it.

In the `Boot Options` page, ensure that `Boot drive #1` is set to `floppy`.

### Other
In this section, you'll want to tick the `Enable port 0xE9 hack`, which will allow us to send output from our kernel through to the host console. This will let us not have to worry about things scrolling off the screen or being lost, since there will be a record of it on your develoment machine.

### Enabling Magic Breakpoints
Save the config file somewhere, I'm saving it as `tools/bochsrc.bxrc`. To enable magic breakpoints, you'll need to edit the configuration file manually (I can't find an option for it in Bochs' setup window).

When looking at the `bochsrc.bxrc` file, try to `Ctrl+F` for `magic_break`. If you find it, it'll likely say `enabled=0`. Change that to `enabled=1`. If it's not there, add a line at the end of the file that says `magic_break: enabled=1`, and that should do it.

## Running Bochs
We can now create a batch file to run it, to make our lives easier.

```bat
@echo off

set scriptDir=%~dp0
set prjRoot=%scriptDir%\..

if not exist %prjRoot%\bin\ (
	echo There is nothing to run...
) else (
	cls
	bochsdbg -q -f %prjRoot%\tools\bochsrc.bxrc
)
```

The two variables at the start simply set some directories, they allow this file to be run from anywhere. `cls` is a command that will clear the screen, you can omit this if you want.

The `-q` flag to `bochsdbg` tells it to start immediately, skipping the setup pop-up menu. We also give it the `-f` flag with a file name, this tells it which configuration file to use.

Running this batch file should give you a debugging window. Bochs will pause the debugger before beginning, so click continue to run. If all goes smoothly, it'll run fully and you'll see your output in the output window.

![Bochs Output]({{ site.baseurl }}{% link /assets/Bochs Output.png %})

## Setting Breakpoints
Breakpoints can be set in code using the instruction `xchg bx, bx`, which will simply exchange what's in the `bx` register with itself (i.e. it'll do nothing). Bochs interprets this instruction as a breakpoint, which is extremely useful.

When it pauses at at a location, you can see the next instructions it will execute, as well as the state of any registers. You can step through the code line by line using the `Step` button (this is akin to a `Step Into` button). If you would just like to step over each line (i.e. not going into any calls, etc.) you will need to type `n` (for "next") into the bar at the bottom.

## Final Thoughts
Have a play around with the Bochs debugger. It's essential you get used to it as it's an extremely useful debugging tool.
