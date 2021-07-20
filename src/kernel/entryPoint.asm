; ===== Date Created: 20 July, 2021 ===== 
bits 32

extern kmain

section .entry

; void start()
global start
start:
	mov esp, kernelStackStart
	call kmain

	.hang:
		cli
		hlt
		jmp .hang

align 16
kernelStackEnd:
	times 16384 db 0
kernelStackStart:
