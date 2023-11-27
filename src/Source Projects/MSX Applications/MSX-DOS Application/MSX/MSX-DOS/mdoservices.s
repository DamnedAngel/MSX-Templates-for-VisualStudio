;----------------------------------------------------------
;		mdoservices.s - by Danilo Angelo, 2023
;
;		Overlay services for MSX-DOS applications.
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.globl _onMDOAbend
		 
mdoStatus_loaded			.equ	#0b00000001
mdoStatus_linked			.equ	#0b00000010

.macro MDO_SERVICES

_mdoFCB::
_mdoFCB_drive_no::			.blkb	1		
_mdoFCB_name::				.blkb	8
_mdoFCB_extension::			.blkb	3
_mdoFCB_current_block::		.blkb	2
_mdoFCB_record_size::		.blkb	2
_mdoFCB_file_size::			.blkb   4
_mdoFCB_date::				.blkb	2
_mdoFCB_time::				.blkb	2
_mdoFCB_device_id::			.blkb	1
_mdoFCB_dirloc::			.blkb	1
_mdoFCB_strcls::			.blkb	2
_mdoFCB_clrcls::			.blkb	2
_mdoFCB_clsoff::			.blkb	2
_mdoFCB_current_record::	.blkb	1
_mdoFCB_random_record::		.blkb	4


;----------------------------------------------------------
;	MDO Handler
mdoHandler::				.dw		0
mdoAddress::				.dw		0

;----------------------------------------------------------
;	Retrieve mdo handler, its address and status,
;	and test if loaded
isMdoLoaded::
	di

.if eq __SDCCCALL
	add		hl, sp
	ld		d, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, d
.endif
	ld		(#mdoHandler), hl
	ld		de, #12
	add		hl, de
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl
	ld		(#mdoAddress), hl
	ld		hl, (#mdoHandler)
	ld		a, (hl)
	and		#mdoStatus_loaded
	ret

;----------------------------------------------------------
;	Retrieve mdo handler, its address and status,
;	and test if loaded and linked
isMdoLinked::
.if eq __SDCCCALL
	ld		hl, #6			; first argument, but after three call instructions!
.endif
	call	isMdoLoaded
	jr z,	mdoService_notLoadedError
	ld		a, (hl)
	and		#mdoStatus_linked
	ret

;-----------------
;	Error routines

	; mdo already loaded error
mdoService_alreadyLoadedError::
	ld		a, #1
	jp nz,	mdoService_finalize

	; mdo not loaded error
mdoService_notLoadedError::
	ld		a, #4
	jp nz,	mdoService_finalize

;----------------------------------------------------------
;	Load and initialize child MDO
;	input: Pointer MDO handler
;	output:
;		0x00: success
;		0x01: mdo already loaded
;		0x02: mdo file signature error
;		0x03: mdo name error
;		0xfe: file read error
;		0xff: file open error
;----------------------------------------------------------
_mdoLoad::
	push	ix				; by sdcc standard, ix must be preserved by the callee
	; retrieve mdo handler and status, and test if loaded
.if eq __SDCCCALL
	ld		hl, #4			; first argument, but after two call instructions!
.endif
	call	isMdoLoaded
	jr nz,	mdoService_alreadyLoadedError

	; reset fcb
	exx
	ld		hl, #_mdoFCB
	ld		de, #_mdoFCB+1
	ld		bc, #36
	ld		(hl), #0
	ldir
	exx
	
	; fill fcb
	inc		hl					
	ld		de, #_mdoFCB_name
	ld		bc, #11				; NAME(8) + EXT(3)
	ldir							

	; open file
	ld		de, #_mdoFCB
	ld		c, #BDOS_FOPEN
	call	BDOS_SYSCAL
	or		a
	jr nz,	mdoService_finalize

	; set mdo address in DTA
	ld		hl, (#mdoAddress)
	ex		de, hl
	ld		c, #BDOS_SETDTA
	call	BDOS_SYSCAL

	; load file
	ld		hl, #1
	ld		(#_mdoFCB_record_size), hl
	ld		de, #_mdoFCB
	ld		hl, (#_mdoFCB_file_size)
	ld		c, #BDOS_RDBLK
	call	BDOS_SYSCAL
	or		a
	jr nz,	mdoLoad_readError

	; assert MDO signature
	ld		hl, (#mdoAddress)
	ld		a, (hl)				; loaded mdo signature
	cp		#'M'
	jr nz,	mdoLoad_signatureError
	inc		hl
	ld		a, (hl)
	cp		#'O'
	jr nz,	mdoLoad_signatureError

	; assert MDO identification
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)				; bc <= loaded mdo name
	ld		hl, (#mdoHandler)
	ld		de, #14				; mdo_name offset
	add		hl, de
	ex		de, hl				; de <= mdo_name in mdoHandler
	ld		l, c
	ld		h, b				; hl <= loaded mdo name
mdoLoad_testMdoNameLoop:
	ld		a, (de)
	or		a
	jr z,	mdoLoad_setStatusLoaded
	cp		(hl)
	jr nz,	mdoLoad_nameError
	inc		hl
	inc		de
	jr		mdoLoad_testMdoNameLoop

	; update mdo status to loaded
mdoLoad_setStatusLoaded:
	ld		hl, (#mdoHandler)	; start of MDO handler 
	ld		(hl), #mdoStatus_loaded
	
	; close fcb
mdoLoad_closefile:
	push	af
	ld		c, #BDOS_FCLOSE
	ld		de, #_mdoFCB
	call	BDOS_SYSCAL

	; call MDO's onLoad routine
	ld		de, #8				; onLoad
	call	callCustomRoutine

	; end
	pop		af

	; finalization routine for all services
mdoService_finalize::
.if eq __SDCCCALL
	ld		l, a
.endif
	ei
	pop		ix				; by sdcc standard, ix must be preserved by the callee
	ret

;----------------------------------------------------------
;	Call MDO's custom onLoad routine
;	input:	DE: offset of routine pointer in MDO header

callCustomRoutine::
	ld		hl, (#mdoAddress)	; start of MDO file
	add		hl, de				; custom routine
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ld		hl, #returnFromCustomRoutine
	push	hl
	push	de
	ret
returnFromCustomRoutine::
	ret
	
;-----------------
;	Error routines

	; mdo file signature error
mdoLoad_signatureError::
	ld		a, #2
	jr		mdoLoad_closefile

	; mdo name error
mdoLoad_nameError::
	ld		a, #3
	jr		mdoLoad_closefile

	; mdo name error
mdoLoad_readError::
	ld		a, #0xfe
	jr		mdoLoad_closefile

;----------------------------------------------------------
;	Finalize and release Child MDO
;	input: Pointer MDO_CHILD structure
;	output:
;		0x00: success
;		0x04: mdo not loaded
;		0x05: mdo linked
;----------------------------------------------------------
_mdoRelease::
	push	ix				; by sdcc standard, ix must be preserved by the callee
	call	isMdoLinked
	jr nz,	mdoService_linkedError

	; update mdo status to unloaded
	ld		hl, (#mdoHandler)	; start of MDO handler 
	ld		(hl), #0
	
	; call MDO's finalize routine
	ld		de, #10				; finalize
	call	callCustomRoutine
	
	; end
	xor		a
	jr		mdoService_finalize

;-----------------
;	Error routines

	; mdo already/still linked error
mdoService_linkedError::
	ld		a, #5
	jr		mdoService_finalize

	; mdo not linked error
mdoService_notLinkedError::
	ld		a, #6
	jr		mdoService_finalize

;-----------------
;	Hook table
getHookImpAddrTable::
	ld		hl, (#mdoAddress)
	ld		de, #6
	add		hl, de				; hl <= pointer to pointer hook implementation table in header
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl				; hl <= pointer to first entry of implementation table
	ret

;----------------------------------------------------------
;	Link and activate Child MDO
;	input: Pointer MDO_CHILD structure
;	output:
;		0x00: success
;		0x04: mdo not loaded
;		0x05: mdo already linked
;----------------------------------------------------------
_mdoLink::
	push	ix				; by sdcc standard, ix must be preserved by the callee
	call	isMdoLinked
	jr nz,	mdoService_linkedError

	; link
	call	getHookImpAddrTable	; hl <= pointer to first entry of implementation table

mdoLink_loop::
	ld		e, (hl)
	inc		hl
	ld		d, (hl)				; de <= hook address
	ld		a, e
	or		d
	jr z,	mdoLink_setStatusLinked
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)				; bc <= routine address
	inc		hl					; hl <= next table entry
	ex		de, hl
	inc		hl					; skip jp opcode
	ld		(hl), c
	inc		hl
	ld		(hl), b				; hook installed
	ex		de, hl				; return next table entry in hl
	jr		mdoLink_loop

mdoLink_setStatusLinked:
	; update mdo status to unloaded
	ld		hl, (#mdoHandler)	; start of MDO handler 
	ld		(hl), #mdoStatus_loaded | #mdoStatus_linked

	; call MDO's activate routine
	ld		de, #12				; activate
	call	callCustomRoutine
	
	; end
	xor		a
	jr		mdoService_finalize

;----------------------------------------------------------
;	Deactivate and unlink Child MDO
;	input: Pointer MDO_CHILD structure
;	output:
;		0x00: success
;		0x04: mdo not loaded
;		0x06: mdo not linked
;----------------------------------------------------------
_mdoUnlink::
	push	ix				; by sdcc standard, ix must be preserved by the callee
	call	isMdoLinked
	jr z,	mdoService_notLinkedError

	; unlink
	call	getHookImpAddrTable	; hl <= pointer to first entry of implementation table
	ld		bc, #_mdoAbend

mdoUnlink_loop::
	ld		e, (hl)
	inc		hl
	ld		d, (hl)				; de <= hook address
	ld		a, e
	or		d
	jr z,	mdoUnlink_setStatusUnlinked
	inc		hl					; hl <= next table entry
	ex		de, hl
	inc		hl					; skip jp opcode
	ld		(hl), c
	inc		hl
	ld		(hl), b				; hook uninstalled
	ex		de, hl				; return next table entry in hl
	jr		mdoUnlink_loop

mdoUnlink_setStatusUnlinked:
	; update mdo status to unloaded
	ld		hl, (#mdoHandler)	; start of MDO handler 
	ld		(hl), #mdoStatus_loaded
	
	; call MDO's deactivate routine
	ld		de, #14				; deactivate
	call	callCustomRoutine
	
	; end
	xor		a
	jp		mdoService_finalize

_mdoAbend::
	call	_onMDOAbend
    jp		programEnd

.endm