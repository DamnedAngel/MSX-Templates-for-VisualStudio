;-------------------------------------------------	
; memorymap.s created automatically by makefile	
; on 22:15:17.37 , 23-Jan-20 			
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
