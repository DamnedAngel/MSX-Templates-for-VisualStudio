;----------------------------------------------------------
;		msxdosapp.s - by Danilo Angelo, 2020-2023
;
;		MSX-DOS program example
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
;	Replace the example code below with your art.
_main::
.if __SDCCCALL & CMDLINE_PARAMETERS
	push	hl				; saves parameter index buffer address
	push	de
.endif
    print	hellomsg
    dbg		bymsg			; only printed in debug mode

.if CMDLINE_PARAMETERS
	print	_linefeed
    print	parametersmsg

.if __SDCCCALL
	pop		de
	pop		hl				; restores param index buffer address
	xor		a
	cp		e				; param count
	jr z,	mainContinue	; continues if no params
	ld		b,e
.else
	ld      ix, #0			
	add     ix, sp
    ld      a, 4(ix)		; retrieves param count from stack
	or		a
	jr z,	mainContinue	; continues if no params
	ld		l, 2(ix)		; retrieve param address from stack
	ld		h, 3(ix)
	ld		b,a
.endif

paramLoop::
	ld		e,(hl)			; gets param address from index
	inc		hl
	ld		d,(hl)
	inc		hl
	ex		de,hl
	push	de
	push	bc
    call	__print			; prints param
	print	_linefeed
	pop		bc
	pop		hl
	djnz	paramLoop
.endif
	
mainContinue:
	print	_linefeed

;   Calls MDO example, id MDO_SUPPORT enabled
.if MDO_SUPPORT
	.globl	_useMDO
	call	_useMDO
.else
.if __SDCCCALL
	xor		a
.else
    ld      l, #0
.endif
.endif

mainEnding:
;   Returns to MSX-DOS
	ret


		.area	_DATA

; ----------------------------------------------------------
;	Messages
hellomsg::
.if __SDCCCALL
.asciz		"Hello MSX from Assembly\r\n(sdcccall(REGs))!\r\n"
.else
.asciz		"Hello MSX from Assembly\r\n(sdcccall(STACK))!\r\n"
.endif

bymsg::
.asciz		"Template by\r\nDanilo Angelo.\r\n"

parametersmsg::
.asciz		"Parameters:\r\n"

