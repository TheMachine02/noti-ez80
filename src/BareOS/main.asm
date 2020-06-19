include '../../noti-ez80.inc'
include '../../bareos.inc'
namespace BareOS

OS_BASE:

paduntil OS_BASE+$80
	db "BareOS version 0.03.0002",0
paduntil OS_BASE+$F0
	db "noti OS",0,0,0,0,0,3,0,2,0
	db $5A,$A5,$FF,$01
include 'table.asm'
include 'code.asm'
include 'expressions.asm'
include 'fs.asm'
include 'data.asm'

endOfOS:

end namespace

