;----------------------------------------------------------
;		mdostructures.s - by Danilo Angelo, 2023
;
;		Overlay structures for MSX-DOS applications.
;----------------------------------------------------------

.globl	_abendMDO

.macro MDO_NAME	name
	.area _MDONAME
	.ascii		name
	.db			0
.endm

.macro MDO_HOOK		routine
	.area _MDOHOOKS
	 routine:				
	 routine'.hook::			
	    jp		_abendMDO
.endm

.macro MDO_HOOK_IMPLEMENTATION		hookname, routine
	.area _MDOHOOKIMPLEMENTATIONS
	.dw			hookname'.hook
	.globl		routine
	.dw			routine
.endm
