
include '../include/ez80.inc'
include '../include/ti84pceg.inc'

macro paduntil? addr
	assert $ <= addr
	if $ < addr
		db addr-$ dup $FF
	end if
end macro

macro riemann
	ret
	db $FF,$FF,$FF
end macro

calminstruction (var) strcalc? val
	compute val, val        ; compute expression
	arrange val, val        ; convert result to a decimal token
	stringify val           ; convert decimal token to string
	publish var, val
end calminstruction

macro .def
end macro

macro .assume
end macro

macro .ref
end macro

define endif? end if

TOTAL_ROM_SIZE=0

org 0
START_OF_ROM:
__SECTOR_00h:		;Bootloader goes here
	include 'boot.asm'

LEN_OF_BOOT strcalc $-START_OF_ROM

paduntil $010000

BARE_OS_START:=$+80
include 'BareOS/main.asm'

	LEN_OF_BARE_OS strcalc $-BARE_OS_START
	display "BareOS Length:",LEN_OF_BARE_OS,$0A
	TOTAL_ROM_SIZE = TOTAL_ROM_SIZE+$-BARE_OS_START

	LEN_OF_ALL_CODE strcalc TOTAL_ROM_SIZE
	display "Total code size:",LEN_OF_ALL_CODE,$0A

paduntil $020000

