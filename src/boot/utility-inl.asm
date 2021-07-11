; ===== Date Created: 11 July, 2021 ===== 

; void reboot()
reboot:
	.notify:
		mov si, rebootMessage
		call print_string

	.wait_for_key_press:
		xor ax, ax
		int 0x16

	.restart:
		jmp word 0xffff:0x0000

; void clear_screen()
clear_screen:
	.clear:
		mov ax, 0x0700			; Entire screen
		mov bx, 0x07			; Colour (black background, white foreground)
		xor cx, cx				; Top-left of screen is (0, 0)
		mov dx, 0x184f			; Screen size: 24 rows x 79 columns
		int 0x10

	.move_cursor:
		mov ax, 0x02
		xor dx, dx				; Move to (0, 0)
		xor bh, bh				; Page 0
		int 0x10

	.cleanup:
		ret

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
