---
layout: page
title:  "CHS Addressing"
slug:  "chs-addressing"
date:   2021-07-11 20:31:27 +1000
---

Oh boy, this one's gonna be a bit calculation heavy (which isn't very fun in assembly to be honest). We are going to be starting our dive into the world of disk reading, and for that we're going to intimately understand the drives themselves. Buckle up!

## The Disk
A hard drive is made of a series of spinning disks (called platters), each with either one or two read/write heads (in the case of two, there'll be one above and below the disk to interact with both sides). Each platter has tracks going around it, with sectors making up small parts of each track. Have a look at the diagrams to get a better sense of it.

![Hard Drive Geometry Image]({{ site.baseurl }}{% link /assets/Hard Drive Geometry 0.png %})

***Source: [Wikipedia](https://commons.wikimedia.org/wiki/File:Hard_drive_geometry_-_English_-_2019-05-30.svg)***

<br>

![Hard Drive Geometry Image]({{ site.baseurl }}{% link /assets/Hard Drive Geometry 1.png %})

***Source: [IEB-IT Wiki](https://sites.google.com/site/iebitwiki/hardware/secondary-storage/hard-disk-drive)***

<br>

## What is CHS Addressing?
CHS addressing stands for "Cylinder-Head-Sector" (which you might notice are parts of the drive!) and is a way of referring to data on the disk. You tell the disk exactly which cylinder, head, and sector you want to read from/write to, and it'll do just that.

## Alternatives to CHS
There exists an alternative form of addressing called LBA (Logical Block Addressing). It's honestly much nicer to use, all you do is give the drive a sector number to interact with. 

### Why don't we use it?
Currently, we're emulating booting off a floppy drive. Floppy drives don't often have a way of addressing using LBA, so we're forced to use CHS addressing for now. We could later configure our setup to boot off a virtual hard disk, but that requires a bit of work.

## The Code For Calculation
So given a linear sector number, we should be able to calculate the cylinder, head, and sector number its on if we know how many sectors per track there are and how many heads per cylinder there are. We're going to assume that we're using a 2880 kiB floppy with 36 sectors per track and 2 heads per cylinder. Why? This is the default for QEMU. The default for Bochs is a 1440 kiB floppy with 18 sectors per track, so our calculations will break there (don't worry, we'll fix that later).

