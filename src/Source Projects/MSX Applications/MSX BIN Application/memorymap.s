;-------------------------------------------------	
; memorymap.s created automatically by makefile	
; on 11:11:39.83 , 31-Jan-20 			
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
