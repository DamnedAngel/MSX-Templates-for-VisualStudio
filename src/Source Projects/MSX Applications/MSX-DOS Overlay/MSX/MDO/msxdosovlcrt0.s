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

;----------------------------------------------------------
;	Step 1: Initialize globals
.if GLOBALS_INITIALIZER
	call    gsinit
.endif


;----------------------------------------------------------
;	Step 2: VDP port fix
.if VDP_PORT_FIX
    ld      a,(#BIOS_EXPTBL)
    ld      hl, #BIOS_VDPDR
    call    BIOS_RDSLT
    ld      hl, #vdpInPortMap
    ld      b,  a
    call    vdpPortFix

    ld      a,(#BIOS_EXPTBL)
    ld      hl, #BIOS_VDPDW
    call    BIOS_RDSLT
    ld      hl, #vdpOutPortMap
    ld      b,  a
    call    vdpPortFix

    ei
.endif


;----------------------------------------------------------
;	Step 3: Initialize MDO
    jp      _initialize


;----------------------------------------------------------
;	VDP Port Fix helper routine
.if VDP_PORT_FIX
vdpPortFix::
   ld      a, (hl)     ; relative port
   cp      #0xff
   ret z
   add     a, b        ; a = port
   inc     hl
   ld      e, (hl)
   inc     hl
   ld      d, (hl)     ; de = address to be fixed
   ld      (de), a
   inc     hl
   jr      vdpPortFix
.endif

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

 .if VDP_PORT_FIX
    .area _VDPINPORTMAP
    .area _VDPINPORTMAPFINAL
    .area _VDPOUTPORTMAP
    .area _VDPOUTPORTMAPFINAL
.endif

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


;   ==================================
;   ======== VDP FIX SEGMENTS ========
;   ==================================

 .if VDP_PORT_FIX
;----------------------------------------------------------
;	VDP in port map
    .area _VDPINPORTMAP
vdpInPortMap::
    .area _VDPINPORTMAPFINAL
vdpInPortMapFinal::
    .db     #0xff

;----------------------------------------------------------
;	VDP out port map
    .area _VDPOUTPORTMAP
vdpOutPortMap::
    .area _VDPOUTPORTMAPFINAL
vdpOutPortMapFinal::
    .db     #0xff
.endif


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

