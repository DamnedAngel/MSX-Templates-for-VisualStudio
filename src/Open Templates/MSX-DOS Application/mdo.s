;----------------------------------------------------------
;		mdo.s - by Danilo Angelo, 2020-2023
;
;		MDO support in MSX-DOS program example
;		Assembly version
;
;       This file is only needed when using MDOs
;       and may be ignored otherwise.
;----------------------------------------------------------

	.include "applicationsettings.s"

.if MDO_SUPPORT
	.area	_CODE

;----------------------------------------------------------
; This is an example how to use MDOs (overlay modules)
; Replace the code below to implement your own MDO.
;----------------------------------------------------------
    .include "targetconfig.s"
	.include "mdointerface.s"
	.include "printinterface.s"

	_useMDO::
	print	msgUsage

	; load MDO
	ld		hl, #_OVERLAY_ONE
.if eq __SDCCCALL
	push	hl
	call	_mdoLoad
	ld		a, l
	pop		hl
.else
	call	_mdoLoad
.endif
	or		a
	ld		hl, #msgloaderror
	jr nz,	#useMDOerror
	dbg		msgloadsuccess

	; link MDO
	ld		hl, #_OVERLAY_ONE
.if eq __SDCCCALL
	push	hl
	call	_mdoLink
	ld		a, l
	pop		hl
.else
	call	_mdoLink
.endif
	or		a
	ld		hl, #msglinkerror
	jr nz,	#useMDOerror
	dbg		msglinksuccess
	
	call	_mdoChildHello_hook			; routine in MDO
	call	_mdoChildGoodbye_hook		; routine in MDO

	; unlink MDO
	ld		hl, #_OVERLAY_ONE
.if eq __SDCCCALL
	push	hl
	call	_mdoUnlink
	ld		a, l
	pop		hl
.else
	call	_mdoUnlink
.endif
	or		a
	ld		hl, #msgunlinkerror
	jr nz,	#useMDOerror
	dbg		msgunlinksuccess

	; release MDO
	ld		hl, #_OVERLAY_ONE
.if eq __SDCCCALL
	push	hl
	call	_mdoRelease
	ld		a, l
	pop		hl
.else
	call	_mdoRelease
.endif
	or		a
;call	_mdoRelease
;	or		a
;.if eq __SDCCCALL
;	ld		a, l
;.endif
	ld		hl, #msgreleaseerror
	jr nz,	#useMDOerror
	dbg		msgreleasesuccess

.if __SDCCCALL
	xor		a
.else
    ld      l, #0
.endif
	ret

useMDOerror::
;	hl has pointer to error message
;	a has errorcode, but in this example
;	we will ignore it and return #0xa0
;	error code for all MDO errors.
	call	__print
.if __SDCCCALL
	ld		a, #0xa0
.else
    ld      l, #0xa0
.endif
	ret

;	----------------------------------------------------------
;	This is called when a MDO hook is called before it is
;	linked to a child MDO. The application will terminate
;	after the return of this routine.
;	Customize here the finalization of you application.
_onMDOAbend::
	ld		hl, #msgMDOAbend
	call	__print
.if __SDCCCALL
	ld		a, #0xa1	; termination code
.else
    ld      l, #0xa1	; termination code
.endif
	ret


	.area	_DATA

; ----------------------------------------------------------
;	MDO related messages

msgUsage::
.asciz		"MDO usage example in ASM.\r\n"
msgloaderror::
.asciz		"Error loading MDO.\r\n"
msgloadsuccess::
.asciz		"MDO loaded successfully.\r\n"
msglinkerror::
.asciz		"Error linking MDO.\r\n"
msglinksuccess::
.asciz		"MDO linked successfully.\r\n"
msgunlinkerror::
.asciz		"Error unlinking MDO.\r\n"
msgunlinksuccess::
.asciz		"MDO unlinked successfully.\r\n"
msgreleaseerror::
.asciz		"Error releasing MDO.\r\n"
msgreleasesuccess::
.asciz		"MDO released successfully.\r\n"
msgMDOAbend::
.asciz		"Undefined hook called.\r\n"

.endif