;----------------------------------------------------------
;		mdointerface.s - by Danilo Angelo, 2023
;
;		Interface for MDO's features.
;----------------------------------------------------------
	.include "applicationsettings.s"
	.globl s__AFTERHEAP

.if OVERLAY_SUPPORT
	; ----------------------------------------------------------
	;	MDO's structure definition.
	;   DON'T CHANGE IT.
	.include "MSX/MSX-DOS/mdostructures.s"

	;----------------------------------------------------------
	;	MDO name
	MDO_NAME	APPLICATION
	
	;----------------------------------------------------------
	;	MDO hooks
	MDO_HOOK	mdoChildHello
	MDO_HOOK	mdoChildGoodbye

	;----------------------------------------------------------
	;	Children MDOs
	;	Syntax: MDO_CHILD mdoname, filename, extension, starting address
	;	Notes:
	;	  - if filename is less than 8 characters, the rest must be filled in by spaces.
	;	  - if extension is less than 3 characters, the rest must be filled in by spaces.
	MDO_CHILD	OVERLAY_ONE, ^/MSXOVL1 /, MDO, #s__AFTERHEAP
.endif
	