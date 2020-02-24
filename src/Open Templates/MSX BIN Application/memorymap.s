;-------------------------------------------------	
; memorymap.s created automatically by makefile	
; on  6:49:14.94 , 24-Feb-20 			
;													
; DO NOT BOTHER EDITING THIS.						
; ALL CHANGES YOUR BE LOST.						
;-------------------------------------------------	
													
fileStart .equ 0xb000						
												
.area _CODE									
												
.macro USRCALLSINDEX							
													
.globl _printFromBasic								
.dw _printFromBasic								
													
.endm											
