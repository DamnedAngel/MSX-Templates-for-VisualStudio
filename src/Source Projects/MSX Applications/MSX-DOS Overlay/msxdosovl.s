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
;	This is the custom initialization function for your C MDO.
;	Invoked when the MDO is loaded.
_initialize::
    ld		hl,	#_initializemsg
    call	print
	ret

; ----------------------------------------------------------
;	This is the custom finalization function for your C MDO!
;	Invoked when the MDO is unloaded.
_finalize::
    ld		hl,	#_finalizemsg
    call	print
	ret

; ----------------------------------------------------------
;	This is the custom activation function for your C MDO!
;	Invoked when the MDO is linked.
_activate::
    ld		hl,	#_activatemsg
    call	print
	ret

; ----------------------------------------------------------
;	This is the custom deactivation function for your C MDO!
;	Invoked when the MDO is unlinked.
_deactivate::
    ld		hl,	#_deactivatemsg
    call	print
	ret

; ----------------------------------------------------------
;	These are examples of dinamically linked function
;  which may be called by parent module
_hello::
    ld		hl,	#_hellomsg
    call	print
	ret

_goodbye::
    ld		hl,	#_goodbyemsg
    call	print
	ret

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
_initializemsg::
.if __SDCCCALL
.ascii		"MDO in ASM (sdcccall(REGs)) initialized!\r\n\0"
.else
.ascii		"MDO in ASM (sdcccall(STACK)) initialized!\r\n\0"
.endif
_finalizemsg::
.ascii		"MDO finalized!\r\n\0"
_activatemsg::
.ascii		"MDO activated!\r\n\0"
_deactivatemsg::
.ascii		"MDO deactivated!\r\n\0"

_hellomsg::
.ascii		"Hello MSX from dinamically linked function!\r\n\0"
_goodbyemsg::
.ascii		"Goodbye MSX from dinamically linked function!\r\n\0"

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif
