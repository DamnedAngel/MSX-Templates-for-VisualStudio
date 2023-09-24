;----------------------------------------------------------
;		msxbinapp.s - by Danilo Angelo, 2020-2023
;
;		BIN program (BLOAD'able) for MSX example
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"

	.area	_CODE

	.globl	_print
	.globl	_debug

; ----------------------------------------------------------
;	This is the main function for your ASM MSX APP!
;
;	Your fun starts here!!!
;	Replace the code below with your art.
_main::
;   Replace the two lines below with your own program logic
    ld hl, #_msg
    call _printMSG

;   Return to BASIC
    ret

; ----------------------------------------------------------
;   Once you replaced the commands in the _main routine
;   above with your own program, you should delete the
;   lines below. They are for demonstration purposes only.
; ----------------------------------------------------------

; ----------------------------------------------------------
;	This is an example of an ASM routine accessible
;	by BASIC USR calls.
;	Please also check the reference to the routine in 
;	ApplicationSettings.txt file.
;	This is only for the demo app.
;	You can safely remove it for your application.
_printFromBasic::
	ld hl, (#BIOS_USRDATA)

; ----------------------------------------------------------
;	This is an example of using debug code in ASM.
;	This is only for the demo app.
;	You can safely remove it for your application.
_printMSG:
.if DEBUG
	push hl
    ld hl, #_msgdbg
	call _printMSG_loop
	pop hl
.endif
_printMSG_loop:
    ld a,(hl)
    or a
    ret z
    call BIOS_CHPUT
    inc hl
    jr _printMSG_loop

		.area	_DATA

; ----------------------------------------------------------
;	Hello Message
_msg::
.if __SDCCCALL
.ascii		"Hello MSX from Assembly (sdcccall(REGs))!\r\n\0"
.else
.ascii		"Hello MSX from Assembly (sdcccall(STACK))!\r\n\0"
.endif

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif
