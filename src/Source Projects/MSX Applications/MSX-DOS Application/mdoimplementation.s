;-------------------------------------------------			
; mdoimplementation.s created automatically				
; by make.bat												
; on  8:29:48.92 , Sun 09/17/2023 					
;															
; DO NOT BOTHER EDITING THIS.								
; ALL CHANGES WILL BE LOST.								
;-------------------------------------------------			
.globl s__AFTERHEAP										
															
.include "./MSX/MSX-DOS/mdostructures.s"	
MDO_NAME	APPLICATION										
MDO_HOOK	mdoChildHello									
MDO_HOOK	mdoChildGoodbye									
MDO_CHILD	OVERLAY_ONE ^/MSXOVL1 / MDO #s__AFTERHEAP									
