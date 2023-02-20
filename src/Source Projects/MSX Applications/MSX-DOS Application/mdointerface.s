;----------------------------------------------------------
;		mdointerface.s - by Danilo Angelo, 2023
;
;		Interface for MDO's features.
;----------------------------------------------------------

	.include "applicationsettings.s"

.if OVERLAY_SUPPORT
	.include "MSX/MSX-DOS/mdostructures.s"

	MDO_NAME	"APPLICATION"
	
	MDO_HOOK	mdoChildHello
	MDO_HOOK	mdoChildGoodbye
.endif
	