;----------------------------------------------------------
;		msxbinapp.s - by Danilo Angelo, 2020
;
;		BIN program (BLOAD'able) for MSX example
;		Assembly version
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX\BIOS\msxbios.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is the main function for your ASM MSX APP!
;
;	Your fun starts here!!!
;	Replace the code below with your art.
_main::
    ld hl, #_msg
    call _printMSG
	ld l, #0
	ret

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
	push	hl
	ld		iy, (#0xfcc0)	; BIOS_ROMSLT
	ld		ix, #0x00a2		; BIOS_CHPUT
	call	#0x001c			; BIOS_CALSLT
	pop		hl
    inc hl
    jr _printMSG_loop

		.area	_DATA

; ----------------------------------------------------------
;	Debug Message
_msg::
.ascii		"Hello MSX from Assembly!\r\n\0"

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif
