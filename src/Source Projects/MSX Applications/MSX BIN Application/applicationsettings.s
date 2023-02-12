;-------------------------------------------------		
; applicationsettings.s created automatically			
; by make.bat											
; on 13:49:14.10 , Sun 02/12/2023 				
;														
; DO NOT BOTHER EDITING THIS.							
; ALL CHANGES WILL BE LOST.							
;-------------------------------------------------		
														
GLOBALS_INITIALIZER = 1				
PUBLISH_FILESTART = 1								
__SDCCCALL = 0							
fileStart .equ 0xb000							
.macro MCR_USRCALLSINDEX							
												
_BASIC_USR_INDEX::								
										
.globl _printFromBasic									
.dw _printFromBasic									
.endm												
