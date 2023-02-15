;----------------------------------------------------------
;		msxbincrt0.s - by Danilo Angelo, 2020-2023
;
;		Template for BIN (BLOADable) programs for MSX 
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"

	.globl	_main

.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
    .globl  s__INITIALIZED
    .globl  s__INITIALIZER
.endif

;   ====================================
;   ========== HEADER SEGMENT ==========
;   ====================================
	.area	_HEADER (ABS,CON)
	.org    #fileStart - #7

;----------------------------------------------------------
;	BIN Header
	.db		#0xfe			; BIN ID
	.dw		#fileStart		; Start address
	.dw		#fileEnd - #1	; End address
	.dw		#init			; Entry point

;----------------------------------------------------------
;	Build user call index
	MCR_USRCALLSINDEX

;----------------------------------------------------------
;	Step 1: Publish File Start at (HIMEM - 1)
init::
.if PUBLISH_FILESTART
	ld		hl, (#BIOS_HIMEM)
	dec		hl
	ld		bc, #fileStart
	ld		(hl), b
	dec		hl
	ld		(hl), c
.endif

;----------------------------------------------------------
;	Step 2: Initialize globals
.if GLOBALS_INITIALIZER
	call    gsinit
.endif

;----------------------------------------------------------
;	Step 3: Run application (RET returns to BASIC)
	jp		_main

;----------------------------------------------------------
;	Segments order
;----------------------------------------------------------
    .area _CODE
	.area _HOME
    .area _GSINIT
    .area _GSFINAL
    .area _INITIALIZER
    .area _DATA
    .area _INITIALIZED
    .area _HEAP
	
;   =====================================
;   ========== GSINIT SEGMENTS ==========
;   =====================================
.if GLOBALS_INITIALIZER
	.area	_GSINIT
gsinit::
    ld      bc,#l__INITIALIZER
    ld      a,b
    or      a,c
    jp	z,  gsinit_next
    ld	    de,#s__INITIALIZED
    ld      hl,#s__INITIALIZER
    ldir

	.area	_GSFINAL
gsinit_next:
    ret
.endif

;   ==================================
;   ========== DATA SEGMENT ==========
;   ==================================
	.area	_DATA
_heap_top::
	.dw     _HEAP_start

;   ==================================
;   ========== HEAP SEGMENT ==========
;   ==================================
    .area	_HEAP
_HEAP_start::
fileEnd: