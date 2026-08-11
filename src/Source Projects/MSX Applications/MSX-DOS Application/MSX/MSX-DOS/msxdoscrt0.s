;----------------------------------------------------------
;		msxdoscrt0.s - by Danilo Angelo, 2020-2026
;
;		Template for COM (executable) programs for MSX-DOS
;		Derived from the work of Konamiman/Avelino
;			https://github.com/Konamiman/MSX/blob/master/SRC/SDCC/crt0-msxdos/crt0msx_msxdos.asm
;			https://github.com/Konamiman/MSX/blob/master/SRC/SDCC/crt0-msxdos/crt0msx_msxdos_advanced.asm
;----------------------------------------------------------

	.include "msxbios.s"
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
    jp      start


;----------------------------------------------------------
;	Step 5: Program termination.
;	Termination code for DOS 2 was returned:
;   - on l for sdcccall(0);
;   - on a for sdcccall(1).
programEnd:
.if __SDCCCALL
    ld      b,a         ; termination code
.else
    pop     de          ; clear Parameter Table address from stack
    pop     de

    ld      b,l         ; termination code
.endif
    ld      c,#0x62	    ; DOS 2 function for program termination (_TERM)
    call    5			; On DOS 2 this terminates; on DOS 1 this returns...
    ld      c,#0x0
    jp      5			;...and then this one terminates
						;(DOS 1 function for program termination).


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
    .area _DATA
    .area _INITIALIZED
    .area _HEAP
    .area _AFTERHEAP
    .area _POSTHEAP
    .area _INITIALIZER

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



;   ==================================
;   ========== DATA SEGMENT ==========
;   ==================================
    .area	_DATA
_heap_top::
	.dw     _HEAP_start

CMD_TABLE:
    .ds     2*MAX_CMDLINE_PARAMETERS   ; 0 bytes when MAX_CMDLINE_PARAMETERS is 0

;   ==================================
;   ========== HEAP SEGMENT ==========
;   ==================================
    .area	_HEAP
_HEAP_start::
    .ds #HEAP_SIZE

;   ==================================
;   ===== POST-HEAP PARAM ROUTINE ====
;   ==================================
;	Placed after _AFTERHEAP, so it never counts toward it: an MDO or the
;	app's own memory-management scheme may safely reuse this address once
;	the routine has run - it only ever executes once, at startup.
    .area	_POSTHEAP
start::
;----------------------------------------------------------
;	Step 1: VDP port fix
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
;	Step 2: Initialize globals (GSINIT)
.if GLOBALS_INITIALIZER
    ld      bc,#l__INITIALIZER
    ld      a,b
    or      a,c
    jp	z,  gsinit_end
    ld	    de,#s__INITIALIZED
    ld      hl,#s__INITIALIZER
    ldir
.endif

gsinit_end:

;----------------------------------------------------------
;	Step 3: Process command line paramenters
.if MAX_CMDLINE_PARAMETERS
    ;* Check if there are any parameters at all
    ld      a,(#0x80)
    or      a
    ld      e,#0
    jr z,   parend
        
    ;* Terminate command line with 0
    ;  (DOS 2 does this automatically but DOS 1 does not)
    ld      hl, #0x81
    ld      e, a
    ld      d, #0
    add     hl, de
    ld      (hl), #0
        
    ;* Initialize registers and call the parsing routine.
    ld      hl, #0x81       ;Command line pointer
    ld      e, #0           ;Number of params found
    ld      ix, #CMD_TABLE  ;Params table pointer

    ;* Loop over the command line: skip spaces
parloop:
	ld      a,(hl)
    or      a               ;Command line end found?
    jr z,   parend

    cp      #32
    jr nz,  parfnd
    inc     hl
    jr      parloop

    ;* Parameter found: add its address to params table...
parfnd:
	ld      (ix),l
    ld      1(ix),h
    inc     ix
    inc     ix
    inc     e

    ld      a,e             ;protection against too many parameters - CMD_TABLE
                            ;is strictly sized for MAX_CMDLINE_PARAMETERS entries
    cp      #MAX_CMDLINE_PARAMETERS
    jr nc,  parend

    ;* ...and skip chars until finding a space or command line end
parloop2:
	ld      a,(hl)
    or      a               ;Command line end found?
    jr z,   parend    

    cp      #32
    jr nz,  parnospc        ;If space found, set it to 0
                            ;(string terminator)...
    ld      (hl),#0
    inc     hl
    jr      parloop         ;...and return to space skipping loop

parnospc:
	inc     hl
    jr      parloop2

parend:
    ld      d,#0
.else
    ld      de,#0
.endif

	ld      hl,#CMD_TABLE


;----------------------------------------------------------
;	Step 4: Run application
.if eq __SDCCCALL
    push    de              ; Pass info as parameters to "main"
    push    hl
.endif
    ; "Call" main, returning to programEnd
    ld      bc, #programEnd     
    push	bc
    jp      _main

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