---
layout: page
title: "Introduction"
slug: "introduction"
---

The chapters under this heading will focus mostly on the kernel. This doesn't mean that we'll be ditching the bootloader completely though, we'll still need to work on it to get some kernel things working.

## A Common Header
I generally like to have a common header file where I can put things that I'll need in most of my source files. Let's create a file `system/common.hpp`.

### Only Clang
To be honest, I don't know if this kernel works on other compilers (it definitely doesn't with MSVC, not too sure with GCC). That doesn't mean you can't follow along with those compilers, it just means there's no *official* support for them. Just to make sure we're on Clang, I have this error in my common file.

```cpp
#if !defined(__clang__)
#error Clang is the only compiler supported right now...
#endif
```

### Common Macros
I have a couple macros in this header too, one simply does nothing with its argument (it gets rid of a compiler warning when you haven't used a parameter yet). The other is a macro to set a breakpoint, using the same `xchg bx, bx` instruction as before. We use inline assembly for this, which uses GCC's syntax rather than Intel syntax (which is what NASM is based on). This is a bit annoying, but alright since we're not going to be doing too much inline assembly.

```cpp
#define UNUSED(x) (void) (x)
#define BREAK_POINT() asm volatile("xchg %%bx, %%bx" ::)
```

### Common Types
I personally like to have my basic types shortened. You obviously don't need to do this though. One quirk of this is that I'd like to be able to do `const u8* str = "Hello";`, but `u8` would be `unsigned char` rather than just `char`. The solution? Define `u8` as a `char` but force char to be `unsigned` through a compiler flag.

```cpp
// Common types
using s8 = signed char;
using s16 = short;
using s32 = int;
using s64 = long long;

using u8 = char;
using u16 = unsigned short;
using u32 = unsigned int;
using u64 = unsigned long long;
using usize = u32;

using f32 = float;
using f64 = double;
```

Note that `usize` is a `u32` here, since we're in 32-bit mode. Once we implement stuff in 64-bit Long Mode we'll have to change that.

To force `char` to be `unsigned` by default, we need to add this flag to our build file:

```bash
-funsigned-char
```

We can now also replace all our types in `kernel.cpp` with these, like so:

```cpp
#include "system/common.hpp"

extern "C" void kmain()
{
	u8* address = (u8*) 0xb8000;
	const u8* string = "Hello, world!";
	u16 stringSize = 13;

	for (u16 i = 0; i < stringSize; i++)
	{
		*address = (u8) string[i];
		address += 1;
		*address = (u8) 0x9f;
		address += 1;
	}

	while (true);
}
```

## Final Thoughts
That's it for this chapter, if all has gone well the output should not have changed.

See the code in full [here](https://github.com/FancyKillerPanda/OS-Tutorial/tree/).
