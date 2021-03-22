;----------------------------------------------------------
;		msxromapp.s - by Danilo Angelo, 2020
;
;		ROM program (cartridge) for MSX example
;		Assembly version
;----------------------------------------------------------

	.include "targetconfig.s"
	.include "MSX/BIOS/msxbios.s"
	.include "applicationsettings.s"

	.area	_CODE

STRING_COMPARE = 0

; ----------------------------------------------------------
;	This is the main function for your ASM MSX APP!
;
;	Your fun starts here!!!
;	Replace the code below with your art.
_main::
;   Replace the two lines below with your own program logic
    ld hl, #_msg
    call _printMSG

;   Return to BASIC
    ret


.if CALL_EXPANSION
; ----------------------------------------------------------
;	This is a CALL handler example.
;	CALL CMD1
;
;	This is only for the demo app.
;	To disable the support for BASIC's CALL statement:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's CALL statement from the project:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
;	3) Remove all onCallXXXXX functions from this file
_onCallCMD1::
    ld      hl, #_msgCMD1
    call    _printMSG

	ld      hl, #2			; retrieve param address from stack
	add     hl, sp
	ld		b, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, b
_onCallCMD1_findEndOfCommand:
    ld      a, (hl)
    cp      #0
    ret z
    cp      #0x3a
    ret z
    inc     hl
    jr      _onCallCMD1_findEndOfCommand

; ----------------------------------------------------------
;	This is a CALL handler example.
;	CALL CMD2
;
;	This is only for the demo app.
;	To disable the support for BASIC's CALL statement:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's CALL statement from the project:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
;	3) Remove all onCallXXXXX functions from this file
_onCallCMD2::
    ld      hl, #_msgCMD2
    call    _printMSG

	ld      hl, #2			; retrieve param address from stack
	add     hl, sp
	ld		b, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, b
_onCallCMD2_findEndOfCommand:
    ld      a, (hl)
    cp      #0
    ret z
    cp      #0x3a
    ret z
    inc     hl
    jr      _onCallCMD2_findEndOfCommand
.endif

.if DEVICE_EXPANSION
; ----------------------------------------------------------
;	This is a DEVICE getID handler example.
;	"DEV:"
;
;	This is only for the demo app.
;	To disable the support for BASIC's devices:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's devices from the project:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all DEVICE items in ApplicationSettings.txt
;	3) Remove all onDeviceXXXXX_getId and onDeviceXXXXX_IO routines from this file
_onDeviceDEV_getId::
    ld      hl, #_msgDEV_getId
    call    _printMSG
    ld      l, #0
    ret

; ----------------------------------------------------------
;	This is a DEVICE IO handler example.
;	"DEV:"
;
;	This is only for the demo app.
;	To disable the support for BASIC's devices:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's devices from the project:
;	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all DEVICE items in ApplicationSettings.txt
;	3) Remove all onDeviceXXXXX_getId and onDeviceXXXXX_IO routines from this file
_onDeviceDEV_IO::
    ld      hl, #_msgDEV_IO
    call    _printMSG
    ret
.endif

; ----------------------------------------------------------
;   Once you replaced the commands in the _main routine
;   above with your own program, you should delete the
;   lines below. They are for demonstration purposes only.
; ----------------------------------------------------------

; ----------------------------------------------------------
;	This is an example of using debug code in ASM.
;	This is only for the demo app.
;	You can safely remove it for your application.
_printMSG:
.if DEBUG
	push hl
    ld hl, #_msgdbg
	call _printMSG_loop
	pop hl
.endif
_printMSG_loop:
    ld a,(hl)
    or a
    ret z
    call BIOS_CHPUT
    inc hl
    jr _printMSG_loop

	.area	_ROMDATA

; ----------------------------------------------------------
;	Debug Message
_msg::
.ascii		"Hello MSX from Assembly!\r\n"
.ascii		"If you don't want your\r\n"
.ascii		"ROM program to return to\r\n"
.ascii		"BASIC/MSX-DOS, just avoid\r\n"
.ascii      "the RET instruction.\r\n\0"

.if CALL_EXPANSION
_msgCMD1::
.ascii		"The ASM handler for CMD1 says hi!\r\n\0"
_msgCMD2::
.ascii		"The ASM handler for CMD2 says hi!\r\n\0"
.endif

.if DEVICE_EXPANSION
_msgDEV_getId::
.ascii		"The ASM handler for DEV_getId says hi!\r\n\0"
_msgDEV_IO::
.ascii		"The ASM handler for DEV_IO says hi!\r\n\0"
.endif

; ----------------------------------------------------------
;	Debug Message
;	Another example of debug code in ASM.
.if DEBUG
_msgdbg::
.ascii		"[DEBUG]\0"
.endif

	.area	_DATA
