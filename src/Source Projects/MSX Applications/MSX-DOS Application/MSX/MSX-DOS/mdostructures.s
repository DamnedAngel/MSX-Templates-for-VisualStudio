;----------------------------------------------------------
;		mdostructures.s - by Danilo Angelo, 2023
;
;		Overlay structures for MSX-DOS applications.
;----------------------------------------------------------

.globl	_abendMDO

.macro MDO_NAME	name
	.area _MDONAME
_mdoName::
	.ascii		name
.endm

.macro MDO_HOOK		routine
	.area _MDOHOOK
	 routine:				
	 routine'.hook::			
	    jp		_abendMDO
.endm

.macro MDO_HOOK_IMPLEMENTATION		hookname, routine
	.area _MDOHOOKIMPLEMENTATION
	.dw			hookname'.hook
	.dw			routine
.endm
