;----------------------------------------------------------
;		msxdosovlcrt0.s - by Danilo Angelo, 2023
;
;		Template for MDO (MSX-DOS Overlay)
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"

	.globl	_initialize
	.globl  _finalize
    .globl  _activate
    .globl  _deactivate
    
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
	.db		'M'					    ; MDO ID
	.db		'O'					    ; MDO ID
	.dw		#mdoName			    ; MDO Name
	.dw		#mdoHooks			    ; Forward Hooks
	.dw		#mdoHookImplementations	; Reserved
    .dw		#onLoad				    ; Initialization routine
	.dw		#_finalize			    ; Finalization routine
	.dw		#_activate			    ; Activation (linkage) routine
	.dw		#_deactivate		    ; Deactivation (de-linkage) routine

;----------------------------------------------------------
;	Initialization routine
;----------------------------------------------------------
onLoad::
.if GLOBALS_INITIALIZER
	call    gsinit
.endif
    jp      _initialize

;----------------------------------------------------------
;	Segments order
;----------------------------------------------------------
    .area _CODE

    .area _MDONAME
    .area _MDOHOOKS
    .area _MDOCHILDLIST
    .area _MDOCHILDLISTFINAL
    .area _MDOCHILDREN
    .area _MDOHOOKIMPLEMENTATIONS
    .area _MDOHOOKIMPLEMENTATIONSFINAL
    .area _MDOSERVICES

    .area _HOME
    .area _GSINIT
    .area _GSFINAL
    .area _INITIALIZER
    .area _DATA
    .area _INITIALIZED
    .area _HEAP
    .area _AFTERHEAP

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
;	MDO child list
	.area	_MDOCHILDLIST
mdoChildList::

    .area _MDOCHILDLISTFINAL
mdoChildListFinal::
    .dw     #0

;----------------------------------------------------------
;	MDO child
	.area	_MDOCHILDREN
mdoChildren:

;----------------------------------------------------------
;	MDO Hook Implementation
	.area	_MDOHOOKIMPLEMENTATIONS
mdoHookImplementations::

	.area	_MDOHOOKIMPLEMENTATIONSFINAL
mdoHookImplementationsFinal::
    .dw     0

;----------------------------------------------------------
;	MDO services
	.area	_MDOSERVICES

.include "mdoimplementation.s"

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

