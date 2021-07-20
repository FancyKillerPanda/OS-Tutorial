; ===== Date Created: 20 July, 2021 ===== 

%macro enable_protected_mode 0
	%%.setup:
		mov si, enableProtectedModeMessage
		call print_string

		cli

		; NOTE(fkp): This requires that we have already
		; described the GDT and IDT tables.
		lgdt [gdtEntry]
		lidt [idtEntry]

		mov word [bootloaderStackPointer], sp

	%%.enable:
		; Enables protected mode
		mov eax, cr0
		or eax, 1
		mov cr0, eax

		; Also clears the prefetch queue
		jmp gdtCode32Offset:%%.setup_segments
		nop
		nop

	%%.setup_segments:
		bits 32
		; Selects the data descriptor for all segments (except cs)
		mov eax, gdtData32Offset
		mov ds, eax
		mov es, eax
		mov fs, eax
		mov gs, eax
		mov ss, eax
		mov esp, 0x20000		; Still within usable memory
%endmacro
