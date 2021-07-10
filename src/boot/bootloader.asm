org 0x7c00

start:
	mov ah, 0x0e
	mov al, 'A'
	xor bx, bx
	int 0x10

	jmp $

end:
	times 510 - ($ - $$) db 0
	dw 0xaa55
