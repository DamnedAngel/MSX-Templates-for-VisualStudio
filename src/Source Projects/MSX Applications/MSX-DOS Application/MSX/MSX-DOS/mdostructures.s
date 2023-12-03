;----------------------------------------------------------
;		mdostructures.s - by Danilo Angelo, 2023
;
;		Overlay structures for MSX-DOS applications.
;----------------------------------------------------------

.globl	_mdoAbend

.macro MDO_NAME	name
	.area _MDONAME
	.asciz		"name"
.endm

.macro MDO_HOOK		hookname
	.area _MDOHOOKS
	 hookname:				
	 _'hookname'_hook::			
	    jp		_mdoAbend
.endm

.macro MDO_HOOK_IMPLEMENTATION		hookname, routine
	.area _MDOHOOKIMPLEMENTATIONS
	.globl		_'hookname'_hook
	.dw			_'hookname'_hook
	.globl		routine
	.dw			routine
.endm

.macro MDO_CHILD	mdoname, filename, extension, address
	.area _MDOCHILDLIST
	.dw			_'mdoname

	.area _MDOCHILDREN
	_'mdoname'::
	mdoname'_status:	.db		#0
	mdoname'_filename:	.ascii	"filename"
	mdoname'_extension:	.ascii	"extension"
	mdoname'_address:	.dw		address
	mdoname'_name:		.asciz	"mdoname"
.endm
