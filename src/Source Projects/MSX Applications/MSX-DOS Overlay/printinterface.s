;----------------------------------------------------------
;		printinterface.s - by Danilo Angelo, 2023
;
;		Interface for print and debug functionalities.
;----------------------------------------------------------

.globl __print
.globl _linefeed

.macro print msg
	ld		hl, #msg
	call	__print
.endm

.macro dbg msg
.if DEBUG
	.globl	_msgdbg
	print	_msgdbg
	print	msg
.endif
.endm
