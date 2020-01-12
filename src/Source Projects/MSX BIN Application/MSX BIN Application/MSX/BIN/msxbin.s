;----------------------------------------------------------
;		msxbin.s - by Danilo Angelo 2020
;
;		Template for BIN programs (BLOAD'able) for MSX 
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX\BIOS\msxbios.s"
	.include "memorymap.s"

;
;	set filestart before .including this file
;
	.globl	_main
	.area	_HEADER (ABS)
	.org    #fileStart - #7
;
; header
;
.db         #0xfe
.dw			#fileStart
.dw			#fileEnd - #1
.dw			#_main

;	.area	_USRINDEX (ABS)
;	.org    #fileStart

	.area	_CODE
_BASIC_USR_INDEX::
	MEMORYMAP

	.area	_DATA

	.area   _GSFINAL
fileEnd:
