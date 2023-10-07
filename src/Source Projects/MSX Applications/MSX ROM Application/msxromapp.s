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

;   Return to BASIC/BOOT
    ret


	.area	_ROMDATA

; ----------------------------------------------------------
;	Messages
hellomsg::
.if __SDCCCALL
.ascii		"Hello MSX from Assembly (sdcccall(REGs))!\r\n"
.else
.ascii		"Hello MSX from Assembly (sdcccall(STACK))!\r\n"
.endif
.ascii		"If you don't want your\r\n"
.ascii		"ROM program to return to\r\n"
.ascii		"BASIC/MSX-DOS, just avoid\r\n"
.asciz      "the RET instruction.\r\n"

bymsg::
.asciz		"Template by Danilo Angelo\r\n"

