;----------------------------------------------------------
;		msxromcrt0.s - by Danilo Angelo 2020
;
;		Template for ROM (cartridges) programs for MSX 
;		Derived from the work of mvac7/303bcn
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX\BIOS\msxbios.s"
	.include "applicationsettings.s"

	.globl	_main
.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
    .globl  s__INITIALIZED
    .globl  s__INITIALIZER
.endif
.if CALL_EXPANSION
    .globl  _call_expansion
.endif
.if DEVICE_EXPANSION
    .globl  _device_expansion
.endif

	.area _HEADER (ABS)
  	.org	#fileStart
;----------------------------------------------------------
;	ROM header
	.db		#0x41				; ID
	.db		#0x42				; ID
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
;	crt0
init::
.ifne RETURN_TO_BASIC
.if STACK_HIMEM
	di
	ld		sp, (#BIOS_HIMEM)		;Stack at the top of memory.
	ei
.endif
.endif

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

.if RETURN_TO_BASIC
	jp		_main
.else
	call	_main
	RST		0 ;CHKRAM
.endif  

;----------------------------------------------------------
;	Order of other segments
	.area	_CODE
		.area   _GSINIT
		.area   _GSFINAL
		.area	_INITIALIZER
		.area	_ROMDATA
	.area	_DATA
		.area	_INITIALIZED
		.area	_HEAP	

;----------------------------------------------------------
;	Variable initializer
	.area   _GSINIT
gsinit::
	ld		hl, #_HEAP_start
	ld		(#_heap_top), hl
.if GLOBALS_INITIALIZER
	ld		bc, #l__INITIALIZER
	ld		a, b
	or		a, c
	jp		z,_main
	ld		de, #s__INITIALIZED
	ld		hl, #s__INITIALIZER
	ldir
.endif

gsinext:
	.area   _GSFINAL
	jp		_main

	.area	_DATA
_heap_top::
	.blkw	1

	.area	_INITIALIZED

	.area	_HEAP
_HEAP_start::
