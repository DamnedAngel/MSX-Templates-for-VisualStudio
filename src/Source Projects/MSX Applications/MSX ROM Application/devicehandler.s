;----------------------------------------------------------
;		devicehandler.s - by Danilo Angelo, 2023
;
;		BASIC's DEVICE handler example
;		Assembly version
;
;       This file is only needed when implementing
;       a new BASIC DEVICE and may be ignored otherwise.
;----------------------------------------------------------

	.include "applicationsettings.s"

.if DEVICE_EXPANSION
	.include "printinterface.s"

	.area	_CODE

; ----------------------------------------------------------
;	This is a DEVICE getID handler example.
;	"DEV:"
;
;	PLEASE NOTE THAT SUPPORT FOR DEVICE EXPANSION
;	IS EMBRYONIC AND FAR FROM COMPLETE!
;
;	This is only for the demo app.
;	To disable the support for BASIC's devices:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's devices from the project:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all DEVICE items in ApplicationSettings.txt
;	3) Remove all onDeviceXXXXX_getId and onDeviceXXXXX_IO routines from this file
_onDeviceDEV_getId::
    print   _msgDEV_getId
    ld      l, #0
    ret

; ----------------------------------------------------------
;	This is a DEVICE IO handler example.
;	"DEV:"
;
;	PLEASE NOTE THAT SUPPORT FOR DEVICE EXPANSION
;	IS EMBRYONIC AND FAR FROM COMPLETE!
;
;	This is only for the demo app.
;	To disable the support for BASIC's devices:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's devices from the project:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all DEVICE items in ApplicationSettings.txt
;	3) Remove all onDeviceXXXXX_getId and onDeviceXXXXX_IO routines from this file
_onDeviceDEV_IO::
    print   _msgDEV_IO
    ret


	.area	_ROMDATA

; ----------------------------------------------------------
;	Messages
_msgDEV_getId::
.asciz		"The ASM handler for DEV_getId says hi!\r\n"
_msgDEV_IO::
.asciz		"The ASM handler for DEV_IO says hi!\r\n"

.endif      ; DEVICE_EXPANSION