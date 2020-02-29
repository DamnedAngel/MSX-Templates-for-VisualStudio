;-------------------------------------------------	
; applicationsettings.s created automatically		
; by makefile										
; on  9:18:55.88 , 29-Feb-20 			
;													
; DO NOT BOTHER EDITING THIS.						
; ALL CHANGES WILL BE LOST.						
;-------------------------------------------------	
													
GLOBALS_INITIALIZER = 1							
PUBLISH_FILESTART = 1							
fileStart .equ 0xb000						
												
												
.macro USRCALLSINDEX							
													
.globl _printFromBasic								
.dw _printFromBasic								
													
.endm											
