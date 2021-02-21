;----------------------------------------------------------
;		msxromcrt0.s - by Danilo Angelo 2020
;
;		Template for ROM (cartridges) programs for MSX 
;		Derived from the work of mvac7/303bcn
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX/BIOS/msxbios.s"
	.include "applicationsettings.s"

	.globl	_main

.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
    .globl  s__INITIALIZED
    .globl  s__INITIALIZER
.endif

.if DEVICE_EXPANSION
    .globl  _device_expansion
.endif

STR_COMPARE = 0

;   ====================================
;   ========== HEADER SEGMENT ==========
;   ====================================
	.area	_HEADER (ABS)
  	.org	#fileStart

;----------------------------------------------------------
;	ROM Header
	.db		#0x41				; ROM ID
	.db		#0x42				; ROM ID
	.dw		#init				; Program start
.if CALL_EXPANSION
	.dw		#_call_expansion	; BASIC's CALL instruction expansion routine
.else
	.dw		#0x0000				; BASIC's CALL instruction not expanded
.endif
.if DEVICE_EXPANSION
	.dw		#_device_expansion	; BASIC's IO DEVICE expansion routine
.else
	.dw		#0x0000				; BASIC's IO DEVICE not expanded
.endif
	.dw		#BASIC_PROGRAM		; BASIC program
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved

;----------------------------------------------------------
;	Step 1: Initialize heap pointer
init::
	ld		hl, #_HEAP_start
	ld		(#_heap_top), hl

;----------------------------------------------------------
;	Step 2: Initialize globals
    call    gsinit

;----------------------------------------------------------
;	Step 3: Sets stack to HIMEM
.ifne RETURN_TO_BASIC
.if STACK_HIMEM
	di
	ld		sp, (#BIOS_HIMEM)		;Stack at the top of memory.
	ei
.endif
.endif

;----------------------------------------------------------
;	Step 4: Enables page 2 on the same slot/subslot as page 1
;           (useful for 32kb ROMs on pages 1 and 2)
.if SET_PAGE_2
	di
	call	#BIOS_RSLREG
	rrca
	rrca
	and		#0x03	
	ld		c, a
	ld		hl, #BIOS_EXPTBL
	add		a, l
	ld		l, a
	ld		a, (hl)
	and		#0x80
	or		c
	ld		c, a
	inc		l
	inc		l
	inc		l
	inc		l
	ld		a, (hl)
	and		#0x0c
	or		c
	ld		h, #0x80
	call	#BIOS_ENASLT
	ei
.endif

;----------------------------------------------------------
;	Step 5: Run application
.if RETURN_TO_BASIC
	jp		_main
.else
	call	_main
	RST		0 ;CHKRAM
.endif 

;----------------------------------------------------------
;	Segments order
;----------------------------------------------------------
	.area _CODE
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _INITIALIZER
	.area _ROMDATA
	.area _DATA
	.area _INITIALIZED
	.area _HEAP

;   ==================================
;   ========== HOME SEGMENT ==========
;   ==================================
	.area _HOME
.if CALL_EXPANSION
STR_COMPARE = 1
_call_expansion::
	exx
	ld		hl, #callStatementIndex
	jr		callExpansionParseStmt

callExpansionStmtNotFound:
	pop hl

callExpansionParseStmt:	
;	get pointer to statement in table
	xor		a
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	cp		e
	jr nz,	callExpansionNotEndOfList
	cp		d
	jr nz,	callExpansionNotEndOfList
;	statement not found; end expansion
	exx
	scf
	ret

callExpansionNotEndOfList:
	inc		hl
	push	hl

;	get pointer to statement in CALL
	ld		hl, #BIOS_PROCNM
	call	compareString
	jr nz,	callExpansionStmtNotFound
;	statement found; execute and exit
	pop		hl
	inc		de
	push	de
	exx
	pop		de				; *handler
	push	hl				; parameters
	ld		hl, #callExpansionFinalize
	push	hl				; finalize
	ex		de, hl
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	push	de				; handler
	ret						; calls handler with return to finalize below
							; handler must return hl pointing to end of command (end of line or ":")
	
callExpansionFinalize:
; at this point, hl must be pointing to end of command (end of line or ":")
	pop		hl
	or		a				; resets CY flag
	ret
.endif

.if DEVICE_EXPANSION
STR_COMPARE = 1
_device_expansion::
	exx
	ex		af, af'			; saves phase of operation in af'
	ld		hl, #deviceIndex
	jr		deviceExpansionParseStmt

deviceNotFound:
	pop hl

deviceExpansionParseStmt:	
;	get pointer to device in table
	xor		a
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	cp		e
	jr nz,	deviceExpansionNotEndOfList
	cp		d
	jr nz,	deviceExpansionNotEndOfList
;	statement not found; end expansion
	exx
	ex		af, af'			; restores phase of operation from af'
	scf
	ret

deviceExpansionNotEndOfList:
	inc		hl
	push	hl

;	get pointer to program´s device
	ld		hl, #BIOS_PROCNM
	call	compareString
	jr nz,	deviceNotFound
;	device found; execute and exit
	ex		af, af'			; restores phase of operation from af'
	cp		#0xff			; if device probe (getId)
	jr nz,	deviceExpansionHandlerCall
	inc		de
	inc		de

deviceExpansionHandlerCall:
	pop		hl
	push	de
	exx
	pop		de				; *handler
	inc		de

	push	hl				; parameters
	ld		h, a
	push	hl				; IO command
	inc		sp
	ld		hl,	#deviceExpansionFinalize
	push	hl				; finalize
	ex		de, hl
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	push	de				; handler
	ret						; calls handler with return to finalize below
							; handler must return hl pointing to end of command (end of line or ":")
	
deviceExpansionFinalize:
; at this point, l must contain device number (0-3)
	inc		sp
	ld		a, l
	pop		hl
	or		a				; resets CY flag without destroying A
	ret

.endif

.if STR_COMPARE
compareString::
	ld		a, (hl)
	ld		b, a
	ld		a, (de)
	cp		b
	ret nz
	cp		#0
	ret z
	inc		hl
	inc		de
	jr		compareString
.endif

;   =====================================
;   ========== GSINIT SEGMENTS ==========
;   =====================================
	.area	_GSINIT
gsinit::
.if GLOBALS_INITIALIZER
    ld      bc,#l__INITIALIZER
    ld      a,b
    or      a,c
    jp	z,  gsinit_next
    ld	    de,#s__INITIALIZED
    ld      hl,#s__INITIALIZER
    ldir
.endif

	.area	_GSFINAL
gsinit_next:
    ret
	
;   ======================================
;   ========== ROM_DATA SEGMENT ==========
;   ======================================
	.area	_ROMDATA
.if CALL_EXPANSION
	MCR_CALLEXPANSIONINDEX
.endif

.if DEVICE_EXPANSION
	MCR_DEVICEEXPANSIONINDEX
.endif

;   ==================================
;   ========== DATA SEGMENT ==========
;   ==================================
	.area	_DATA
_heap_top::
	.blkw	1

;   ==================================
;   ========== HEAP SEGMENT ==========
;   ==================================
	.area	_HEAP
_HEAP_start::
