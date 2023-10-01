;----------------------------------------------------------
;		msxbinapp.s - by Danilo Angelo, 2020-2023
;
;		BIN program (BLOAD'able) for MSX example
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

	
	.area	_DATA

; ----------------------------------------------------------
;	Hello Message
hellomsg::
.if __SDCCCALL
.asciz		"Hello MSX from Assembly (sdcccall(REGs))!\r\n"
.else
.asciz		"Hello MSX from Assembly (sdcccall(STACK))!\r\n"
.endif

bymsg::
.asciz		"Template by Danilo Angelo\r\n"