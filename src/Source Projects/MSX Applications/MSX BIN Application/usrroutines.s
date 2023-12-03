;----------------------------------------------------------
;		usrroutines.s - by Danilo Angelo, 2023
;
;		Example od routines to be called by
;       BASIC's USR() function
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "printinterface.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is an example of an ASM routine accessible
;	by BASIC USR calls.
;	Please also check the reference to the routine in 
;	ApplicationSettings.txt file.
_printFromBasic::
	dbg		printmsg
	ld hl,	(#BIOS_USRDATA)
	jp		__print


	.area	_DATA

; ----------------------------------------------------------
;	Messages
printmsg:
.asciz		"ASM version of _printFromBasic called!\r\n"
