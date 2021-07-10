org 0x7c00

start:
	xor ax, ax
	mov ds, ax

	mov si, stringToPrint
	call print_string

	mov si, stringToPrint
	call print_string

	jmp $

; void print_string(ds:si string)
print_string:
	.print_char:
		; Gets a character and compares it with NULL
		mov al, [ds:si]
		cmp al, 0
		je .done

		; Calls the interuupt to print a character
		mov ah, 0x0e
		xor bx, bx
		int 0x10

		; Move to the next character
		inc si
		jmp .print_char

	.done:
		ret

CR: equ 0x0d
LF: equ 0x0a
stringToPrint: db "Hello, world!", CR, LF, 0

end:
	times 510 - ($ - $$) db 0
	dw 0xaa55
