; ===== Date Created: 16 July, 2021 ===== 
bits 16

%macro finish_if_a20_enabled 0
	call check_a20
	cmp ax, 0
	jne .success
%endmacro

; void try_enable_a20()
try_enable_a20:
	.try:
		finish_if_a20_enabled
		call try_set_a20_bios
		finish_if_a20_enabled
		call try_set_a20_keyboard
		finish_if_a20_enabled
		call try_set_a20_fast
		finish_if_a20_enabled

	.fail:
		mov si, a20FailedMessage
		call print_string
		call reboot

	.success:
		mov si, a20SuccessMessage
		call print_string
		ret

; void try_set_a20_bios()
try_set_a20_bios:
	ret

; void try_set_a20_keyboard()
try_set_a20_keyboard:
	ret

; void try_set_a20_fast()
try_set_a20_fast:
	ret

; void check_a20()
check_a20:
	ret

a20SuccessMessage: db "Info: Enabled A20 line!", CR, LF, 0
a20FailedMessage: db "Error: Failed to enable A20 line!", CR, LF, 0
