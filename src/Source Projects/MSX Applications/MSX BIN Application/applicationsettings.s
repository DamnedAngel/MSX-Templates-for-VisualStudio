;-------------------------------------------------		
; applicationsettings.s created automatically			
; by make.bat											
; on 11:50:39.95 , Sun 02/12/2023 				
;														
; DO NOT BOTHER EDITING THIS.							
; ALL CHANGES WILL BE LOST.							
;-------------------------------------------------		
														
GLOBALS_INITIALIZER = 1				
PUBLISH_FILESTART = 1								
__SDCCCALL = 1							
fileStart .equ 0xb000							
.macro MCR_USRCALLSINDEX							
												
_BASIC_USR_INDEX::								
										
.globl _printFromBasic									
.dw _printFromBasic									
.endm												
