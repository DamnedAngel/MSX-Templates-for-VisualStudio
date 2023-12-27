;----------------------------------------------------------
;		msxdoscrt0.s - by Danilo Angelo, 2020-2023
;
;		Template for COM (executable) programs for MSX-DOS
;		Derived from the work of Konamiman/Avelino
;			https://github.com/Konamiman/MSX/blob/master/SRC/SDCC/crt0-msxdos/crt0msx_msxdos.asm
;			https://github.com/Konamiman/MSX/blob/master/SRC/SDCC/crt0-msxdos/crt0msx_msxdos_advanced.asm
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
.if MDO_SUPPORT
    .include "MSX/MSX-DOS/mdoservices.s"
.endif

	.globl	_main

.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
    .globl  s__INITIALIZED
    .globl  s__INITIALIZER
.endif

.if PARAM_HANDLING_ROUTINE
phrAddr	.equ PARAM_HANDLING_ROUTINE
.else
phrAddr	.equ _HEAP_start
.endif


;   ====================================
;   ========== HEADER SEGMENT ==========
;   ====================================
    .area   _HEADER (ABS,CON)
	.org    0x0100      ; MSX-DOS .COM programs start address

;----------------------------------------------------------
;	Step 1: Build the parameter pointers table on 0x100,
;    and terminate each parameter with 0.
;    MSX-DOS places the command line length at 0x80 (one byte),
;    and the command line itself at 0x81 (up to 127 characters).
_init::
params::
.if CMDLINE_PARAMETERS
    ;* Check if there are any parameters at all
    ld      a,(#0x80)
    or      a
    ld      c,#0
    jr      z,cont
        
    ;* Terminate command line with 0
    ;  (DOS 2 does this automatically but DOS 1 does not)
    ld      hl, #0x81
    ld      c, a
    ld      b, #0
    add     hl, bc
    ld      (hl), #0
        
    ;* Copy the command line processing code to other RAM area
	;  (may be 0 = HEAP or somewhere else set in 
	;   ApplicationSettings.txt|PARAM_HANDLING_ROUTINE item) and
    ;  and execute it from there, this way the memory of the original
    ;  code can be recycled for the parameter pointers table.
    ;  (The space from 0x100 up to "cont" can be used,
    ;   this is room for about 40 parameters.
    ;   No real world application will handle so many parameters.)
    ld      hl, #parloop
    ld      de, #phrAddr
    ld      bc, #parloopend-#parloop
    ldir
        
    ;* Initialize registers and jump to the loop routine    
    ld      hl, #0x81        ;Command line pointer
    ld      c, #0            ;Number of params found
    ld      ix, #0x100       ;Params table pointer
        
    ld      de, #cont        ;To continue execution at "cont"
    push    de               ;when the routine RETs
    jp      phrAddr
        
    ;>>> Command line processing routine begin
        
    ;* Loop over the command line: skip spaces
parloop:
	ld      a,(hl)
    or      a       ;Command line end found?
    ret z

    cp      #32
    jr      nz,parfnd
    inc     hl
    jr      parloop

    ;* Parameter found: add its address to params table...

parfnd:
	ld      (ix),l
    ld      1(ix),h
    inc     ix
    inc     ix
    inc     c
        
    ld      a,c     ;protection against too many parameters
    cp      #40
    ret nc
        
    ;* ...and skip chars until finding a space or command line end
        
parloop2:
	ld      a,(hl)
    or      a       ;Command line end found?
    ret z
        
    cp      #32
    jr nz,  nospc        ;If space found, set it to 0
                            ;(string terminator)...
    ld      (hl),#0
    inc     hl
    jr      parloop         ;...and return to space skipping loop

nospc:
	inc     hl
    jr      parloop2

parloopend:
    ;>>> Command line processing routine end
    ;* Command line processing done. Here, C=number of parameters.

cont:
    ld      b,#0
.else
    ld      bc,#0
.endif

	ld      hl,#0x100
    push    bc          ;Pass info as parameters to "main"
    push    hl


;----------------------------------------------------------
;	Step 2: Initialize globals
.if GLOBALS_INITIALIZER
	call    gsinit
.endif


;----------------------------------------------------------
;	Step 3: VDP port fix
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
;	Step 4: Run application
.if __SDCCCALL
    pop     hl
    pop     de
	call    _main
.else
	call    _main
    pop     bc
    pop     bc
.endif


;----------------------------------------------------------
;	Step 5: Program termination.
;	Termination code for DOS 2 was returned:
;   - on l for sdcccall(0);
;   - on a for sdcccall(1).
programEnd:
.if __SDCCCALL
    ld      b,a         ; termination code
.else
    ld      b,l         ; termination code
.endif
    ld      c,#0x62	    ; DOS 2 function for program termination (_TERM)
    call    5			; On DOS 2 this terminates; on DOS 1 this returns...
    ld      c,#0x0
    jp      5			;...and then this one terminates
						;(DOS 1 function for program termination).


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

 .if MDO_SUPPORT
    .area _MDONAME
    .area _MDOHOOKS
    .area _MDOCHILDLIST
    .area _MDOCHILDLISTFINAL
    .area _MDOCHILDREN
    .area _MDOSERVICES
.endif

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

.if MDO_SUPPORT
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
;	MDO children
	.area	_MDOCHILDREN
mdoChildren:

;----------------------------------------------------------
;	MDO Services
	.area	_MDOSERVICES
    MDO_SERVICES

.include "mdoimplementation.s"
.endif


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