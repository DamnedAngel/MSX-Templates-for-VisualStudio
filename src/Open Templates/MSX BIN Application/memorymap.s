;-------------------------------------------------		
; memorymap.s created automatically by makefile		
; on 16:39:49.13 , 12-Jan-20 				
;														
; DO NOT BOTHER EDITING THIS.							
; ALL CHANGES YOUR BE LOST.							
;-------------------------------------------------		
														
fileStart .equ 0xb000								
														
.area _CODE											
														
.macro MEMORYMAP										
.globl _printFromBasic										
.dw _printFromBasic										
.endm													
