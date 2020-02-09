;----------------------------------------------------------
;		msxromapp.s - by Danilo Angelo, 2020
;
;		ROM program (cartridge) for MSX example
;		Assembly version
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX\BIOS\msxbios.s"
	.include "applicationsettings.s"

	.area	_CODE

STRING_COMPARE = 0

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


.if CALL_EXPANSION
STRING_COMPARE = 1
_call_expansion::
;   Replace the two lines below with your own program logic
    ld hl, #_call_msg
    call _printMSG

;   Return to BASIC
    ret
.endif


.if DEVICE_EXPANSION
STRING_COMPARE = 1
_device_expansion::
;   Replace the two lines below with your own program logic

;   Return to BASIC
    ret
.endif

.if STRING_COMPARE
_strcmp:
	ld		a, (de)
	ld		b, a
	ld		a, (hl)
	cp		b
	ret nz
	cp		#0
	ret z
	inc de
	inc hl
	jr _strcmp
.endif

; ----------------------------------------------------------
;   Once you replaced the commands in the _main routine
;   above with your own program, you should delete the
;   lines below. They are for demonstration purposes only.
; ----------------------------------------------------------

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

	.area	_ROMDATA

; ----------------------------------------------------------
;	Debug Message
_msg::
.ascii		"Hello MSX from Assembly!\r\n"
.ascii		"If you don't want your\r\n"
.ascii		"ROM program to return to\r\n"
.ascii		"BASIC/MSX-DOS, just avoid\r\n"
.ascii      "the RET instruction.\r\n\0"

_call_msg::
.ascii		"This is the CALL handling routine!\r\n\0"

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif

	.area	_DATA
