org 0x7c00

start:
	jmp start

end:
	times 510 - ($ - $$) db 0
	dw 0xaa55
