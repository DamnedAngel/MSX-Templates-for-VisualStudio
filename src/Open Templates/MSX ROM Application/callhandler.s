;----------------------------------------------------------
;		callhandler.s - by Danilo Angelo, 2023
;
;		BASIC's CALL instruction extender example
;		Assembly version
;
;       This file is only needed when extending 
;       BASIC's CALL instruction and may be
;       ignored otherwise.
;----------------------------------------------------------

	.include "applicationsettings.s"

.if CALL_EXPANSION
	.include "printinterface.s"

    .globl  _romInit

	.area	_CODE

; ----------------------------------------------------------
;	This is a parameterized CALL handler example.
;	CALL CMD1 (<STRING>)
;   return	0: Success; anything else: syntax error
;
;	To disable the support for BASIC's CALL statement:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's CALL statement from the project:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
;	3) Remove all onCallXXXXX functions from this file
_onCallCMD1::
.ifeq __SDCCCALL
	ld      ix, #0			; retrieve param address from stack
	add     ix, sp
	ld		l, 2(ix)
	ld		h, 3(ix)
.endif
    ld      e, l
    ld      d, h
    ld      c, (hl)
    inc     hl
    ld      h, (hl)
    ld      l, c
 _onCallCMD1_findEndOfCommand:
    ld      a, (hl)
    cp      #'('
    jr nz,  _onCallCMD_fail
    inc     hl
    call    _onCallCMD1_ignoreSpaces
    cp      #'"'
    jr nz,  _onCallCMD_fail
    push    hl
    inc     hl
    ld      b, #1
_onCallCMD1_mapString:
    ld      a, (hl)
    inc     hl
    inc     b
    cp      #'"'
    jr nz,  _onCallCMD1_mapString
    call    _onCallCMD1_ignoreSpaces
    cp      #')'
    jr nz,  _onCallCMD_popFail
    inc     hl
    call    _onCallCMD1_ignoreSpaces
    cp      #0
    jr z,   _onCallCMD1_printMsg
    cp      #0x3a
    jr nz,  _onCallCMD_popFail


_onCallCMD1_printMsg:
    push    bc
    ex      de, hl
    ld      (hl), e
    inc     hl
    ld      (hl), d

    print   _msgCMD1_1
    pop     bc
    pop     hl

_onCallCMD1_printString:
    ld      a, (hl)
    push    hl
	ld		iy, (#0xfcc0); BIOS_ROMSLT
	ld		ix, #0x00a2; BIOS_CHPUT
	call	#0x001c; BIOS_CALSLT
    pop     hl
    inc     hl
    djnz    _onCallCMD1_printString

_onCallCMD1_ending:    
    print   _msgCMD1_2
.ifeq __SDCCCALL
    ld      l, #0
.else
    xor     a
.endif
    ret
_onCallCMD1_ignoreSpaces:
    ld      a, (hl)
    cp      #' '
    ret nz
    inc     hl
    jr _onCallCMD1_ignoreSpaces
_onCallCMD_popFail:
    pop bc
_onCallCMD_fail:
.ifeq __SDCCCALL
    ld      l, #0xff
.else
    ld      a, #0xff
.endif
    ret

; ----------------------------------------------------------
;	This is a parameterless CALL handler example.
;	CALL RUNCART
;   return	0: Success; anything else: syntax error
;
;	To disable the support for BASIC's CALL statement:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	To completely remove the support for BASIC's CALL statement from the project:
;	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
;	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
;	3) Remove all onCallXXXXX functions from this file
_onCallRUNCART::
.ifeq __SDCCCALL
	ld      hl, #2			; retrieve param address from stack
	add     hl, sp
	ld		b, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, b
.endif

; find end of command:
    ld      a, (hl)
    cp      #0
    jr z,   _onCallCMD_fail
    cp      #0x3a
    jr z,   _onCallCMD_fail

; call program in cartridge
    call    _romInit        ; run program in cartridge

; end
.ifeq __SDCCCALL
    ld      l, #0
.else
    xor     a
.endif
    ret

	.area	_ROMDATA

; ----------------------------------------------------------
;	Messages
_msgCMD1_1::
.asciz		"The ASM handler for CMD1 says "
_msgCMD1_2::
.asciz		"!\r\n"

.endif      ; CALL_EXPANSION