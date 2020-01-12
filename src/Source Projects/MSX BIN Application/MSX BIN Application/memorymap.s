;-------------------------------------------------		
; memorymap.s created automatically by makefile		
; on 17:28:48.53 , 12-Jan-20 				
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
