;----------------------------------------------------------
;		msxdosovlcrt0.s - by Danilo Angelo, 2023
;
;		Template for MDO (MSX-DOS Overlay)
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
;    INCLUDE_MDO_PARENT_SYMBOL_FILE

	.globl	_initialize
	.globl  _finalize
    
.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
	.globl  s__INITIALIZED
	.globl  s__INITIALIZER
.endif

;   ====================================
;   ========== HEADER SEGMENT ==========
;   ====================================
	.area   _HEADER (ABS,CON)
	.org    #fileStart

;----------------------------------------------------------
;	MDO Header
;----------------------------------------------------------
	.db		'M'					; MDO ID
	.db		'O'					; MDO ID
	.dw		#onLoad				; Initialization routine
	.dw		#onRelease			; Finalization routine
	.dw		#mdoName			; MDO Name
	.dw		#mdoHooks			; Forward Hooks
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved
	.dw		#0x0000				; Reserved

;----------------------------------------------------------
;	Initialization routine
;----------------------------------------------------------
onLoad::

;----------------------------------------------------------
;	Step 2: Initialize globals
.if GLOBALS_INITIALIZER
	call    gsinit
.endif

;----------------------------------------------------------
;	Step 3: Call custom initialization routine
    jp      _initialize


;----------------------------------------------------------
;	Finalization routine
;----------------------------------------------------------
onRelease::
;----------------------------------------------------------
;	Step 1: Call custom finalization routine
    call    _finalize
    
    ret

;----------------------------------------------------------
;	Segments order
;----------------------------------------------------------
    .area _MDONAME
    .area _MDOHOOKS
    .area _MDOHOOKIMPLEMENTATIONS
    .area _MDOHOOKIMPLEMENTATIONSFINAL
    .area _CODE
    .area _HOME
    .area _GSINIT
    .area _GSFINAL
    .area _INITIALIZER
    .area _DATA
    .area _INITIALIZED
    .area _HEAP
    .area _NEXTMODULE

;   ==================================
;   ========== MDO SEGMENTS ==========
;   ==================================

;----------------------------------------------------------
;	MDO name
	.area	_MDONAME
mdoName:

;----------------------------------------------------------
;	MDO hooks
	.area	_MDOHOOKS
mdoHooks:

;----------------------------------------------------------
;	MDO Hook Implementation
	.area	_MDOHOOKIMPLEMENTATIONS
mdoHookIMplementation::

	.area	_MDOHOOKIMPLEMENTATIONSFINAL
mdoHookImplementationFinal::
    .dw     0

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
    .ds #HEAP_SIZE

