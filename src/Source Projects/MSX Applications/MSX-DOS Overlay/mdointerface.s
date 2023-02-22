;----------------------------------------------------------
;		mdointerface.s - by Danilo Angelo, 2023
;
;		Interface for MDO's features.
;----------------------------------------------------------
	.include "targetconfig.s"
	.globl s__AFTERHEAP

	; ----------------------------------------------------------
	;	MDO's structure definition.
	;   BE SURE TO POINT THIS TO mdostructures.s file
	;	EXISTENT IN YOUR MSX-DOS APPLICATION PROJECT!
	.include "../MSX-DOS Application/MSX/MSX-DOS/mdostructures.s"

	;----------------------------------------------------------
	;	Parent's symbol file
	;   BE SURE TO UPDATE THIS EVERY TIME YOU CREATE AN MDO!
.if DEBUG 
	.include "../MSX-DOS Application/Debug/objs/MSXAPP.s"
.else
	.include "../MSX-DOS Application/Release/objs/MSXAPP.s"
.endif

	;----------------------------------------------------------
	;	MDO name
	MDO_NAME	^/OVERLAY_ONE/

	;----------------------------------------------------------
	;	MDO hooks
;	MDO_HOOK	mdoDoSomething
;	MDO_HOOK	mdoDoSomethingElse

	;----------------------------------------------------------
	;	MDO hook implementation
	MDO_HOOK_IMPLEMENTATION	mdoChildHello		_hello
	MDO_HOOK_IMPLEMENTATION	mdoChildGoodbye		_goodbye

	;----------------------------------------------------------
	;	Children MDOs
	;	Syntax: MDO_CHILD mdoname, filename, extension, starting address
	;	Notes:
	;	  - if filename is less than 8 characters, the rest must be filled in by spaces.
	;	  - if extension is less than 3 characters, the rest must be filled in by spaces.
;	MDO_CHILD	^/OVERLAY_TWO/, ^/OVERLAY2/, ^/MDO/, #s__AFTERHEAP
