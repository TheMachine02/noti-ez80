; TODO : create a TI OS compatibility mode for NMI and interrupt handler to speed up default non TI handlers

handler_rst00:
; rst $00 is the start of the boot at reset
	di
	rsmix
	jp.lil	boot_main
	
paduntil	$08
handler_rst08:
; rst $08 is the boot NMI handler
	di
	rsmix
	jp.lil	boot_nmi
	
paduntil	$10
handler_rst10:
;rst $10 - $30 are handled by OS
	di
	rsmix
	jp.lil	$020110 ;rst 10
	
paduntil	$18
handler_rst18:
	di
	rsmix
	jp.lil	$020114 ;rst 18
	
paduntil	$20
handler_rst20:
	di
	rsmix
	jp.lil	$020118 ;rst 20
	
paduntil	$28
handler_rst28:
	di
	rsmix
	jp.lil	$02011C ;rst 28
	
paduntil	$30
handler_rst30:
	di
	rsmix
	jp.lil	$020120 ;rst 30
	
paduntil	$38
handle_rst38:
; interrupt handler in mode im 1
; more complex stuff here
; port 06 is the flash lock status, if set, we may have HUGE issue
	push	af
	push	hl
	in0	a, ($06)
	bit	2, a
	jr	z, .available
	ld	a, $03
	out0	($06),a
.available:
	call	_ChkIfOSInterruptAvailable
._do_boot_handler:
	jp	nz, boot_interrupt_handler
; the TI OS swap shadow and push both ix and iy normally and destroy all shadow
; here, we pass the normal register set as the pseudo shadow, and switch back to restore destroyed register
; hl, af, ix, iy are saved, save also bc and de
	push	bc
	push	de
	call	boot_os_interrupt_jumper
; we'll be back here with interrupt active and shadows swapped
; so swap them again to restore our register and pop saved values
	exx
	ex	af, af'
	pop	de
	pop	bc
	pop	hl
	pop	af
	ret
	
paduntil	$66
handler_nmi:
; the boot NMI check if OS is present, if so, pass the nmi to the OS
	call	_ChkIfOSInterruptAvailable
; TI OS compatibility mode, jump to $0220A8 which is the OS NMI (just crash)
	jp	z, $0220A8
	rst $08

paduntil	$80
;follow with the jump table
include 'table.asm'
include 'table2.asm'
START_OF_CODE:

boot_interrupt_handler:
; default interrupt handler
; for now just acknowledge
	push	bc
	ld	hl, $F00014
	ld	bc, (hl)
	ld	l, $F00008 and $FF
	ld	(hl), bc
	pop	bc
	pop	hl
	pop	af
	ei
	ret

boot_os_interrupt_jumper:
	push	ix
	push	iy
	ld	iy, $D00080
	ld	hl,($D02AD7)
	push	hl
	jp	$02010C

; Checks if OS is valid and ready to receive an interrupt
; Returns nz if not ready or z if ready
_ChkIfOSInterruptAvailable:
	ld	a, (boot_interrupt_ctx)
	or	a, a
	ret	nz
	
; Check if OS is valid
_ChkIfOSAvailable:
boot_check_signature:
	ld	hl, $010100
	ld	a, $5A
	cp	a, (hl)
	ret	nz
	ld	a, $A5
	inc	hl
	cp	a, (hl)
	ret
	
include	'menus.asm'
include	'code.asm'
include	'gfx.asm'
include	'cstd.asm'
include	'rtc_code.asm'
include	'spi_code.asm'
include	'usb_code.asm'
include	'routines.asm'
include	'math.asm'
include	'hexeditor.asm'
include	'restore.asm'

	LEN_OF_CODE strcalc $-START_OF_CODE
	display "Main code length: ",LEN_OF_CODE,$0A
	TOTAL_ROM_SIZE = TOTAL_ROM_SIZE+$-START_OF_CODE

START_OF_DATA:
include	'font.asm'
LCD_Controller_init_data:
	db $38,$03,$0A,$1F
	db $3F,$09,$02,$04
	db $02,$78,$EF,$00
	db $00,$00,$00,$00
	db $00,$00,$D4,$00
	db $00,$00,$00,$00
	db $2D,$09,$00,$00
	db $0C,$00,$00,$00
.len:=$-.

SpiDefaultCommands:
	db $36,$08,$3A,$66
	db $2A,$00,$00,$01
	db $3F,$2B,$00,$00
	db $00,$EF,$B2,$0C
	db $0C, $00, $33, $33, $C0, $2C, $C2, $01, $C4
	db $20, $C6, $0F, $D0, $A4, $A1, $B0, $11, $F0
	db $C0, $22, $E9, $08, $08, $08, $DC, $B7, $35
	db $BB, $17, $C3, $03, $D2, $00, $E0
	db $D0, $00, $00, $10, $0F, $1A, $2D, $54, $3F
	db $3B, $18, $17, $13, $17, $E1, $D0, $00, $00
	db $10, $0F, $09, $2B, $43, $40, $3B, $18, $17
	db $13, $17, $B1, $01, $05, $14, $26, $00
.len:=$-.


include	'strings.asm'

	LEN_OF_DATA strcalc $-START_OF_DATA
	display "Data length: ",LEN_OF_DATA,$0A
	TOTAL_ROM_SIZE = TOTAL_ROM_SIZE+$-START_OF_DATA


boot_interrupt_ctx:=$D177BA
ScrapMem:=$D0017C
FlashByte:=$D0017B
BaseSP:=$D1A87E
textColors:=$D1887C-3
curHeapPtr:=$D1887C-6
asm_program_size:=$D1887C-9
start_of_dynamic_lib_ptr:=$D1887C-12
end_of_dynamic_lib:=$D3FFFF
baseHeap:=$D1887C+1
exec_memory:=$D1A881
