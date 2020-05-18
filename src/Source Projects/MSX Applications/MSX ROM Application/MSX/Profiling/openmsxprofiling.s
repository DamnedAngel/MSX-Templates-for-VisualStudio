; To be used with profile.tcl under OpenMSX
.include "targetconfig.s"

PROFILING_SECTION_PORT	.equ 0x2c
PROFILING_FRAME_PORT	.equ 0x2d

; Starts profiling a section
.macro Section_Profiling_Start, sectionNumber
.if OPENMSX_PROFILING
	ld a, sectionNumber
	in a,(#PROFILING_SECTION_PORT)
.else
.endif
.endm

; Ends profiling a section
.macro Section_Profiling_End, sectionNumber
.if OPENMSX_PROFILING
	ld a, sectionNumber
	out (#PROFILING_SECTION_PORT),a
.endif
.endm
	
; Starts profiling frame
.macro Frame_Profiling_Start
.if OPENMSX_PROFILING
	in a,(#PROFILING_FRAME_PORT)
.endif
.endm

; Ends profiling frame
.macro Frame_Profiling_End
	out (#PROFILING_FRAME_PORT),a
.endif
.endm
