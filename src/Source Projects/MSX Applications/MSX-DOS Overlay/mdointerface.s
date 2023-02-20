;----------------------------------------------------------
;		mdointerface.s - by Danilo Angelo, 2023
;
;		Interface for MDO's features.
;----------------------------------------------------------

	; ----------------------------------------------------------
	;	Replace the paths below to point to
	;	application's mdostructures.s
	;	and exported symbols files
	.include "targetconfig.s"
	.include "../MSX-DOS Application/MSX/MSX-DOS/mdostructures.s"
.if DEBUG 
	.include "../MSX-DOS Application/Debug/objs/MSXAPP.s"
.else
	.include "../MSX-DOS Application/Release/objs/MSXAPP.s"
.endif

	;----------------------------------------------------------
	;	MDO name
	MDO_NAME	"OVERLAY1"
	
	;----------------------------------------------------------
	;	MDO hooks
;	MDO_HOOK	mdoChildHello
;	MDO_HOOK	mdoChildGoodbye

	;----------------------------------------------------------
	;	MDO hook implementation
	MDO_HOOK_IMPLEMENTATION	mdoChildHello		_hello
	MDO_HOOK_IMPLEMENTATION	mdoChildGoodbye		_goodbye
