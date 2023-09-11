;----------------------------------------------------------
;		msxdosapp.s - by Danilo Angelo, 2020-2023
;
;		MSX-DOS program example
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
.if MDO_SUPPORT
    .include "mdointerface.s"
.endif

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
    ld		hl,	#hellomsg
    call	print
.if CMDLINE_PARAMETERS
    ld		hl,	#parametersmsg
    call	print
.if __SDCCCALL
	pop		hl
	xor		a
	cp		e
	jr z,	mainContinue
	ld		b,e
.else
	ld      ix, #0			; retrieve param address from stack
	add     ix, sp
	ld		l, 2(ix)
	ld		h, 3(ix)
    ld      a, 4(ix)
	or		a
	jr z,	mainContinue
	ld		b,a
.endif

paramLoop:
	ld		e,(hl)
	inc		hl
	ld		d,(hl)
	inc		hl
	ex		de,hl
    call	print
	ld		hl,#linefeed
    call	_print
	ex		de,hl
	djnz	paramLoop
.endif
	

mainContinue:
.if MDO_SUPPORT
	call	useMDO
.else
	ld		a, #0
.endif

;   Return to MSX-DOS
mainEnding:
.ifeq __SDCCCALL=0
	ld		l,a
.endif

	ret


;	----------------------------------------------------------
;	This is an example how to use MDOs (overlay modules)
;	Remove it from your application if you're not using overlays.
.if MDO_SUPPORT
	useMDO::
	; load MDO
	ld		hl, #_OVERLAY_ONE
	call	_mdoLoad
	or		a
	ld		hl, #msgloaderror
	jr nz,	#useMDOerror
	ld		hl, #msgloadsuccess
	call	print

	; link MDO
	ld		hl, #_OVERLAY_ONE
	call	_mdoLink
	or		a
	ld		hl, #msglinkerror
	jr nz,	#useMDOerror
	ld		hl, #msglinksuccess
	call	print
	
	call	_mdoChildHello_hook			; routine in MDO
	call	_mdoChildGoodbye_hook		; routine in MDO

	; unlink MDO
	ld		hl, #_OVERLAY_ONE
	call	_mdoUnlink
	or		a
	ld		hl, #msgunlinkerror
	jr nz,	#useMDOerror
	ld		hl, #msgunlinksuccess
	call	print

	; release MDO
	ld		hl, #_OVERLAY_ONE
	call	_mdoRelease
	or		a
	ld		hl, #msgreleaseerror
	jr nz,	#useMDOerror
	ld		hl, #msgreleasesuccess
	call	print

	xor a
	ret

useMDOerror::
;	hl has pointer to error message
;	a has errorcode, but in this example
;	we will ignore it and return #0xa0
;	error code for all MDO errors.
	call	print
	ld		a, #0xa0
	ret

;	----------------------------------------------------------
;	This is called when a MDO hook is called before it is
;	linked to a child MDO. The application will terminate
;	after the return of this routine.
;	Customize here the finalization of you application.
_onMDOAbend::
	ld		hl, #msgMDOAbend
	call	print
.if __SDCCCALL
	ld		a, #0xa1	; termination code
.else
    ld      l, #0xa1	; termination code
.endif
	ret
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
    ld hl,	#msgdbg
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
hellomsg::
.if __SDCCCALL
.ascii		"Hello MSX from Assembly (sdcccall(REGs))!\r\n\0"
.else
.ascii		"Hello MSX from Assembly (sdcccall(STACK))!\r\n\0"
.endif

parametersmsg::
.ascii		"Parameters:"
linefeed::
.ascii		"\r\n\0"

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
msgdbg::
.ascii		"[DEBUG]\0"
.endif

; ----------------------------------------------------------
;	MDO related messages
.if MDO_SUPPORT
msgloaderror::
.ascii		"Error loading MDO.\r\n\0"
msgloadsuccess::
.ascii		"MDO loaded successfully.\r\n\0"
msglinkerror::
.ascii		"Error linking MDO.\r\n\0"
msglinksuccess::
.ascii		"MDO linked successfully.\r\n\0"
msgunlinkerror::
.ascii		"Error unlinking MDO.\r\n\0"
msgunlinksuccess::
.ascii		"MDO unlinked successfully.\r\n\0"
msgreleaseerror::
.ascii		"Error releasing MDO.\r\n\0"
msgreleasesuccess::
.ascii		"MDO released successfully.\r\n\0"
msgMDOAbend::
.ascii		"Undefined hook called.\r\n\0"
.endif