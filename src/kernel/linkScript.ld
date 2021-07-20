/*  ===== Date Created: 20 July, 2021 =====  */

ENTRY(start)

SECTIONS
{
	/* The kernel begins at the 1MB physical mark. */
	. = 0x00100000;

	.text ALIGN(4k) : AT(ADDR(.text))
	{
		*(.entry)
		*(.text .text.*)
	}

	.rodata ALIGN(4k) : AT(ADDR(.rodata))
	{
		*(.rodata .rodata.*)
	}

	.data ALIGN(4k) : AT(ADDR(.data))
	{
		*(.data .data.*)
	}

	/* Not actually *in* the image. */
	.bss ALIGN(4k) : AT(ADDR(.bss))
	{
		*(COMMON)
		*(.bss .bss.*)
	}
}
