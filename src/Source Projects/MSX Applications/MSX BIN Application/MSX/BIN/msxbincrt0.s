;----------------------------------------------------------
;		msxbincrt0.s - by Danilo Angelo 2020
;
;		Template for BIN programs (BLOADable) for MSX 
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

	.area	_HEADER (ABS)
	.org    #fileStart - #7

;----------------------------------------------------------
;	BIN file header
	.db		#0xfe
	.dw		#fileStart
	.dw		#fileEnd - #1
	.dw		#gsinit

;----------------------------------------------------------
;	_CODE AREA
;	Includes USR Index, if any
	.area	_CODE
;	Call macro to build user call index
	USRCALLSINDEX

;----------------------------------------------------------
;	Order of other segments
	.area	_INITIALIZER

;----------------------------------------------------------
;	Variable initializer
	.area   _GSINIT
gsinit::
.if PUBLISH_FILESTART
	ld		hl, (#BIOS_HIMEM)
	dec		hl
	ld		bc, #fileStart
	ld		(hl), b
	dec		hl
	ld		(hl), c
.endif
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
	.dw _HEAP_start

	.area	_INITIALIZED

	.area	_HEAP
_HEAP_start::
fileEnd:
