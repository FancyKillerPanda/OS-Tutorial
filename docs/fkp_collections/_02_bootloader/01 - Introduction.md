---
layout: page
title:  "Introduction"
slug:  "introduction"
date:   2021-07-10 11:14:09 +1000
---

## What's a bootloader?
A bootloader is what brings your operating system to life! Once the BIOS has done what it needs to do, it hands control of the computer over to your bootloader. Your bootloader then sets up everything for your OS, and then hands over to the kernel (which is the main componenet of your operating system).

You don't need to roll your own bootloader - some even say it can be considered a completely separate project to your kernel. But as my goal was to learn about what's actually going on in there, I didn't think it was in my best interest to use a pre-existing bootloader (for example, GRUB or Limine).

## What happens when you hit the power button?
When you hit the power button, the CPU first starts executing some code to initialise the BIOS. Once the BIOS is loaded, it initialises other hardware components, such as your RAM or graphics card. Up to this point, you have no say in what's happening.

After the BIOS has finished all its initialisation, it's then ready to hand over control to your bootloader. It iterates through each drive that's connected (could be a hard drive, SSD, floppies, USB, whatever) and reads its first 512 bytes (called a *sector*) into memory. It checks if the sector that it loaded is a valid bootloader and, if it is, starts executing it (we'll get into specifics soon, when we start writing our bootloader).

If the sector it loaded is not a valid bootsector, the BIOS will simply move on to the next drive. If the BIOS can't find any valid bootsectors, it will fail to boot (and restart the computer).

Side note: not all computers do this. Some boot using a newer system called UEFI, however we will be focussing on the BIOS way of booting for this guide.
