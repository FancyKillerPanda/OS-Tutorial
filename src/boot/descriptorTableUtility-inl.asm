; ===== Date Created: 18 July, 2021 ===== 
bits 16

; void describe_idt()
describe_idt:
	.setup:
		push es
		xor ax, ax
		mov es, ax
		mov di, [idtEntry.pointer]

	.describe:
		mov cx, 1024
		rep stosw

	.cleanup:
		pop es
		ret

idtEntry:
	.size: dw 1024
	.pointer: dd 0x7100

idtEntryRealMode:
	.size: dw 1024
	.pointer: dd 0x0000
