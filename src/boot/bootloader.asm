bits 16							; NOTE(fkp): Bits
org 0x7c00

CR: equ 0x0d
LF: equ 0x0a
BOOTLOADER_STACK_ADDRESS: equ 0xb000

; NOTE(fkp): Jump
start:
	jmp short main
	nop

; NOTE(fkp): BPB
biosParameterBlock: times 87 db 0

main:
	; NOTE(fkp): Remove old string printing
	; mov si, stringToPrint
	; call print_string
	; mov si, stringToPrint
	; call print_string

	; NOTE(fkp): Set up segments
	.setup:
		xor ax, ax
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ss, ax
		mov sp, BOOTLOADER_STACK_ADDRESS ; NOTE(fkp): Stack

		; NOTE(fkp): Boot drive number
		mov [bootDriveNumber], dl

		; NOTE(fkp): New functions
		call clear_screen
		mov si, welcomeMessage
		call print_string

	; NOTE(fkp): Bootloader expansion
	.expand_bootloader:
		mov si, expandingMessage
		call print_string

		; NOTE(fkp): Read disk function
		call read_disk

	.after_expansion:
		jmp expanded_main

; void read_disk()
read_disk:
	ret

%include "utility-inl.asm"

bootDriveNumber: db 0
welcomeMessage: db "OS Tutorial!", CR, LF, 0
expandingMessage: db "Info: Expanding bootloader...", CR, LF, 0
rebootMessage: db "Press any key to reboot...", CR, LF, 0

; NOTE(fkp)
end_of_first_sector:
	times 504 - ($ - $$) db 0

	bootloaderNumberOfExtraSectors: dw 0
	kernelStartSector: dw 0
	kernelNumberOfSectors: dw 0

	dw 0xaa55

; NOTE(fkp): Stub for now
expanded_main:
	jmp $
