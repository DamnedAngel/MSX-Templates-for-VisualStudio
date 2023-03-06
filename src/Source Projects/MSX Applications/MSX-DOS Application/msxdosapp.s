;----------------------------------------------------------
;		msxdosapp.s - by Danilo Angelo, 2020-2023
;
;		MSX-DOS program example
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is the main function for your ASM MSX APP!
;
;	Your fun starts here!!!
;	Replace the code below with your art.
_main::
;   Replace the lines below with your own program logic
.if __SDCCCALL & CMDLINE_PARAMETERS
	push	hl
.endif
    ld		hl,	#_hellomsg
    call	print
.if CMDLINE_PARAMETERS
    ld		hl,	#_parametersmsg
    call	print
.if __SDCCCALL
	pop		hl
	xor		a
	cp		e
	jr z,	_mainContinue
	ld		b,e
.else
	ld      ix, #0			; retrieve param address from stack
	add     ix, sp
	ld		l, 2(ix)
	ld		h, 3(ix)
    ld      a, 4(ix)
	or		a
	jr z,	_mainContinue
	ld		b,a
.endif

_paramLoop:
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	inc		hl
	ex		de,hl
    call	print
	ld		hl,#_linefeed
    call	_print
	ex		de,hl
	djnz	_paramLoop
.endif
	
;   Use MDO
_mainContinue:
.if MDO_SUPPORT
;	ld		hl, #OVERLAY_ONE
.else
	ld		a, #0
.endif

;   Return to MSX-DOS
_mainEnding:
.ifeq __SDCCCALL=0
	ld		l,a
.endif

	ret

.if MDO_SUPPORT
;	----------------------------------------------------------
;	This is an example how to use MDOs (overlay modules)
;	Remove it from your application if you're not using overlays.
useMDO:
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
print:
.if DEBUG
	push	hl
    ld hl,	#_msgdbg
	call	_print
	pop		hl
.endif

_print:
    ld		a,(hl)
    or		a
    ret z
	push	hl
	ld		iy, (#0xfcc0)	; BIOS_ROMSLT
	ld		ix, #0x00a2		; BIOS_CHPUT
	call	#0x001c			; BIOS_CALSLT
	pop		hl
    inc		hl
    jr		_print

		.area	_DATA

; ----------------------------------------------------------
;	Messages
_hellomsg::
.if __SDCCCALL
.ascii		"Hello MSX from Assembly (sdcccall(REGs))!\r\n\0"
.else
.ascii		"Hello MSX from Assembly (sdcccall(STACK))!\r\n\0"
.endif

_parametersmsg::
.ascii		"Parameters:"
_linefeed::
.ascii		"\r\n\0"

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif
