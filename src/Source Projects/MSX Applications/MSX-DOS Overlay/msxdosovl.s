;----------------------------------------------------------
;		msxdosovl.s - by Danilo Angelo, 2020-2023
;
;		MSX-DOS program overlay example
;		Assembly version
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
	.include "printinterface.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is the custom initialization function for your C MDO.
;	Invoked when the MDO is loaded.
_initialize::
    print	_initializemsg
	ret

; ----------------------------------------------------------
;	This is the custom finalization function for your C MDO!
;	Invoked when the MDO is unloaded.
_finalize::
    print	_finalizemsg
	ret

; ----------------------------------------------------------
;	This is the custom activation function for your C MDO!
;	Invoked when the MDO is linked.
_activate::
    print	_activatemsg
	ret

; ----------------------------------------------------------
;	This is the custom deactivation function for your C MDO!
;	Invoked when the MDO is unlinked.
_deactivate::
    print	_deactivatemsg
	ret

; ----------------------------------------------------------
;	These are examples of dinamically linked function
;  which may be called by parent module
_hello::
    print	_hellomsg
	ret

_goodbye::
    print	_goodbyemsg
	ret

		.area	_DATA

; ----------------------------------------------------------
;   Once you replaced the commands in the _main routine
;   above with your own program, you should delete the
;   lines below. They are for demonstration purposes only.
; ----------------------------------------------------------

; ----------------------------------------------------------
;	Messages
_initializemsg::
.if __SDCCCALL
.ascii		"MDO in ASM (sdcccall(REGs)) initialized!\r\n\0"
.else
.ascii		"MDO in ASM (sdcccall(STACK)) initialized!\r\n\0"
.endif
_finalizemsg::
.ascii		"MDO finalized!\r\n\0"
_activatemsg::
.ascii		"MDO activated!\r\n\0"
_deactivatemsg::
.ascii		"MDO deactivated!\r\n\0"

_hellomsg::
.ascii		"Hello MSX from dinamically linked function!\r\n\0"
_goodbyemsg::
.ascii		"Goodbye MSX from dinamically linked function!\r\n\0"
