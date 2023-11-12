;----------------------------------------------------------
;		msxromapp.s - by Danilo Angelo, 2020-2023
;
;		ROM program (cartridge) for MSX example
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
	.include "printinterface.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is the main function for your ASM MSX APP!
;
;	Your fun starts here!!!
;	Replace the code below with your art.
_main::
    print	hellomsg
    dbg		bymsg			; only printed in debug mode
	print	_linefeed

.if LATE_EXECUTION
	.globl	_saveData
	call	_saveData
.endif

;   Return to BASIC/BOOT
    ret


	.area	_ROMDATA

; ----------------------------------------------------------
;	Messages
hellomsg::
.if __SDCCCALL
.ascii		"Hello MSX from Assembly\r\n(sdcccall(REGs))!\r\n"
.else
.ascii		"Hello MSX from Assembly\r\n(sdcccall(STACK))!\r\n"
.endif
.ascii		"If you don't want your\r\n"
.ascii		"ROM program to return to\r\n"
.ascii		"BASIC/MSXDOS, just avoid\r\n"
.asciz      "the RET instruction in _main.\r\n"

bymsg::
.asciz		"Template by\r\nDanilo Angelo.\r\n"

