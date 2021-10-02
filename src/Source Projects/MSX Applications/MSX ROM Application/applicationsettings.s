;-------------------------------------------------		
; applicationsettings.s created automatically			
; by make.bat											
; on 20:18:29.06 , 02-Oct-21 				
;														
; DO NOT BOTHER EDITING THIS.							
; ALL CHANGES WILL BE LOST.							
;-------------------------------------------------		
														
GLOBALS_INITIALIZER = 1								
RETURN_TO_BASIC = 1								
STACK_HIMEM = 0								
SET_PAGE_2 = 0								
fileStart .equ 0x4000							
CALL_EXPANSION = 1								
DEVICE_EXPANSION = 1								
BASIC_PROGRAM = 0								
													
.macro MCR_CALLEXPANSIONINDEX						
callStatementIndex::					
.dw		callStatement_CMD1				
.dw		callStatement_CMD2				
.dw	#0										
.globl		_onCallCMD1						
callStatement_CMD1::						
.ascii		'CMD1\0'							
.dw		_onCallCMD1						
.globl		_onCallCMD2						
callStatement_CMD2::						
.ascii		'CMD2\0'							
.dw		_onCallCMD2						
.endm												
													
.macro MCR_DEVICEEXPANSIONINDEX					
deviceIndex::							
.dw		device_DEV						
.dw	#0										
.globl		_onDeviceDEV_IO					
.globl		_onDeviceDEV_getId				
device_DEV::								
.ascii		'DEV\0'							
.dw		_onDeviceDEV_IO					
.dw		_onDeviceDEV_getId				
.endm												
