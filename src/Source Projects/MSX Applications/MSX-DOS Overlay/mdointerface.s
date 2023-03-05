;-------------------------------------------------			
; mdointerface.s created automatically						
; by make.bat												
; on  7:11:08.81 , Sun 03/05/2023 					
;															
; DO NOT BOTHER EDITING THIS.								
; ALL CHANGES WILL BE LOST.								
;-------------------------------------------------			
.globl s__AFTERHEAP										
															
.include "../MSX-DOS Application/MSX/MSX-DOS/mdostructures.s"	
.include "../MSX-DOS Application/Debug/objs/parentinterface.s"				
MDO_NAME	OVERLAY_ONE										
MDO_HOOK_IMPLEMENTATION	mdoChildHello	_hello									
MDO_HOOK_IMPLEMENTATION	mdoChildGoodbye	_goodbye									
