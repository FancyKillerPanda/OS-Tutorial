/*  ===== Date Created: 20 July, 2021 =====  */

ENTRY(start)

SECTIONS
{
	/* The kernel begins at the 1MB physical mark. */
	. = 0x00100000;

	.text ALIGN(4k) : AT(.)
	{
		*(.entry)
		*(.text .text.*)
	}

	.rodata ALIGN(4k) : AT(.)
	{
		*(.rodata .rodata.*)
	}

	.data ALIGN(4k) : AT(.)
	{
		*(.data .data.*)
	}

	/* Not actually *in* the image. */
	.bss ALIGN(4k) : AT(.)
	{
		*(COMMON)
		*(.bss .bss.*)
	}
}
