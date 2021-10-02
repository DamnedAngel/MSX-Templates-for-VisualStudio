;-------------------------------------------------		
; applicationsettings.s created automatically			
; by make.bat											
; on 19:43:46.47 , 02-Oct-21 				
;														
; DO NOT BOTHER EDITING THIS.							
; ALL CHANGES WILL BE LOST.							
;-------------------------------------------------		
														
GLOBALS_INITIALIZER = 1								
PUBLISH_FILESTART = 1								
fileStart .equ 0xb000							
.macro MCR_USRCALLSINDEX							
												
_BASIC_USR_INDEX::								
										
.globl _printFromBasic									
.dw _printFromBasic									
.endm												
