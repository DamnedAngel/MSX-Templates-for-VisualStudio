;----------------------------------------------------------
;		mdoservices.s - by Danilo Angelo, 2023
;
;		Overlay services for MSX-DOS applications.
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"

mdostatus_loaded			.equ	#0b00000001

.macro MDO_SERVICES

mdohandler:					.dw		0

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
;	Load Child MDO
;	input: Pointer MDO_CHILD structure
;	output:
;		0x00: success
;		0x01: mdo already loaded
;		0x02: mdo file signature error
;		0x03: mdo name error
;		0xfe: file read error
;		0xff: file open error
;----------------------------------------------------------
_mdoLoad::
.if eq __SDCCCALL
	ld		hl, #2
	add		hl, sp
	ld		a, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, a
.endif

	di

	; reset fcb
	exx
	ld		hl, #_mdoFCB
	ld		de, #_mdoFCB+1
	ld		bc, #36
	ld		(hl), #0
	ldir
	exx
	
	; check if mdo is already loaded
	ld		a, (hl)
	and		a, #mdostatus_loaded
	jr nz,	mdoLoad_finalize
	ld		(#mdohandler), hl

	; fill fcb
	inc		hl					
	ld		de, #_mdoFCB_name
	ld		bc, #11				; NAME(8) + EXT(3)
	ldir							
	push	hl					; mdo_address; save for later

	; open file
	ld		de, #_mdoFCB
	ld		c, #BDOS_FOPEN
	call	BDOS_SYSCAL
	or		a
	jr z,	mdoLoad_setdta
	pop		hl
	jr		mdoLoad_finalize

	; set mdo address in DTA
mdoLoad_setdta:
	pop		hl					; mdo_address
	ld		e, (hl)
	inc		hl
	ld		d, (hl)				; de <= mdo addr
	inc		hl					; mdo_name
	push	hl
	push	de
	ld		c, #BDOS_SETDTA
	call	BDOS_SYSCAL

	; load file
	ld		hl, #1
	ld		(#_mdoFCB_record_size), hl
	ld		de, #_mdoFCB
	ld		hl, (#_mdoFCB_file_size)
	ld		c, #BDOS_RDBLK
	call	BDOS_SYSCAL
	pop		hl					; mdo address
	pop		de					; mdo_name
	or		a
	jr z,	mdoLoad_testmdoheader
	ld		a, #0xfe
	jr		mdoLoad_finalize

	; assert MDO identification
mdoLoad_testmdoheader:
	ld		a, (hl)				; loaded mdo signature
	cp		#'M'
	jr nz,	mdoLoad_signatureerror
	inc		hl
	ld		a, (hl)
	cp		#'O'
	jr nz,	mdoLoad_signatureerror

	; assert MDO identification
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		h, (hL)
	ld		l, c				; loaded mdo name
mdoLoad_testmdonameloop:
	ld		a, (de)
	or		a
	jr z,	mdoLoad_setstatusloaded
	cp		(hl)
	jr nz,	mdoLoad_nameerror
	inc		hl
	inc		de
	jr		mdoLoad_testmdonameloop

	; update mdo status to loaded
mdoLoad_setstatusloaded:
	ld		hl, (#mdohandler)	; start of MDO handler 
	ld		(hl), #1
	
	; close fcb
mdoLoad_closefile:
	push	af
	ld		c, #BDOS_FCLOSE
	ld		de, #_mdoFCB
	call	BDOS_SYSCAL

	; call MDO's custom onLoad routine
	ld		hl, (#BDOS_DTA)		; start of MDO file
	ld		de, #12
	add		hl, de				; onLoad
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ld		hl, #mdoLoad_returnfromcustom
	push	hl
	push	de
	ret

mdoLoad_returnfromcustom:
	pop		af

	; end
mdoLoad_finalize:
.if eq __SDCCCALL
	ld		l, a
.endif
	ei
	ret

mdoLoad_signatureerror:
	ld		a, #2				; mdo file signature error
	jr		mdoLoad_closefile

mdoLoad_nameerror:
	ld		a, #3				; mdo name error
	jr		mdoLoad_closefile

;----------------------------------------------------------
;	Load Child MDO
;	input: Pointer MDO_CHILD structure
;	output:
;		0x00: success
;		0x01: mdo already loaded
;		0x02: mdo file signature error
;		0x03: mdo name error
;		0xfe: file read error
;		0xff: file open error
;----------------------------------------------------------
_mdoRelease::
	ret

_mdoActivate::
	ret

_mdoDeactivate::
	ret

_mdoAbend::
.if __SDCCCALL
    ld      a, #0xff     ; termination code
.else
    ld      l, #0xff     ; termination code
.endif
    jp programEnd
.endm