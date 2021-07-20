bits 16
org 0x7c00

CR: equ 0x0d
LF: equ 0x0a
BOOTLOADER_STACK_ADDRESS: equ 0xb000

%include "kernelLoadMacros-inl.asm"

start:
	jmp short main
	nop

biosParameterBlock: times 87 db 0

main:
	.setup:
		xor ax, ax
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ss, ax
		mov sp, BOOTLOADER_STACK_ADDRESS

		mov [bootDriveNumber], dl

		call clear_screen
		mov si, welcomeMessage
		call print_string

	.expand_bootloader:
		mov si, expandingMessage
		call print_string

		; Destination
		mov ax, 0x07e0
		mov es, ax
		xor bx, bx

		; Start sector and length
		mov cl, 1
		mov al, [bootloaderNumberOfExtraSectors]

		call read_disk

	.after_expansion:
		jmp expanded_main

%include "utility-inl.asm"

bootDriveNumber: db 0
welcomeMessage: db "OS Tutorial!", CR, LF, 0
expandingMessage: db "Info: Expanding bootloader...", CR, LF, 0
rebootMessage: db "Press any key to reboot...", CR, LF, 0
diskErrorMessage: db "Error: Failed to read disk!", CR, LF, 0

end_of_first_sector:
	times 504 - ($ - $$) db 0

	bootloaderNumberOfExtraSectors: dw 0
	kernelStartSector: dw 0
	kernelNumberOfSectors: dw 0

	dw 0xaa55

expanded_main:
	mov si, expandedMessage
	call print_string

	call try_enable_a20

	call describe_gdt
	call describe_idt

	call load_kernel
	enable_protected_mode

	jmp $

%include "a20Utility-inl.asm"
%include "descriptorTableUtility-inl.asm"
%include "kernelLoadUtility-inl.asm"

expandedMessage: db "Info: Bootloader expansion successful!", CR, LF, 0
enableProtectedModeMessage: db "Info: Enabling protected mode!", CR, LF, 0
enableRealModeMessage: db "Info: Enabled real mode!", CR, LF, 0

bootloaderStackPointer: dw 0
