;-------------------------------------------------			
; mdoimplementation.s created automatically				
; by make.bat												
; on 20:11:21.04 , Sun 03/12/2023 					
;															
; DO NOT BOTHER EDITING THIS.								
; ALL CHANGES WILL BE LOST.								
;-------------------------------------------------			
.globl s__AFTERHEAP										
															
.include "../MSX-DOS Application/MSX/MSX-DOS/mdostructures.s"	
.include "../MSX-DOS Application/Release/objs/parentinterface.s"				
MDO_NAME	OVERLAY_ONE										
MDO_HOOK_IMPLEMENTATION	mdoChildHello	_hello									
MDO_HOOK_IMPLEMENTATION	mdoChildGoodbye	_goodbye									
