// ----------------------------------------------------------
//		msxbinapp.c - by Danilo Angelo, 2020-2023
//
//		BIN program(BLOAD'able) for MSX example
//		C version
// ----------------------------------------------------------

#include "MSX/BIOS/msxbios.h"
#include "targetconfig.h"
#include "applicationsettings.h"

// ----------------------------------------------------------
//	This is an example of embedding asm code into C.
//	This is only for the demo app.
//	You can safely remove it for your application.
#pragma disable_warning 85	// because the var msg is not used in C context
void _print(char* msg) {
__asm
#if !__SDCCCALL
	ld      hl, #2; retrieve address from stack
	add     hl, sp
	ld		b, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, b
#endif

_print_loop :
	ld		a, (hl)	; print
	or		a
	ret z
	push	hl
	push	ix
	ld		iy, (BIOS_ROMSLT)
	ld		ix, #BIOS_CHPUT
	call	BIOS_CALSLT
	ei				; in some MSXs (i.e. F1XV) CALSLT returns with di.
	pop		ix
	pop		hl
	inc		hl
	jr		_print_loop
__endasm;

	return;
}

// ----------------------------------------------------------
//	This is an example of using debug code in C.
//	This is only for the demo app.
//	You can safely remove it for your application.
void print(char* msg) {
#ifdef DEBUG
	_print("[DEBUG]");
#endif
	_print(msg);
	return;
}

// ----------------------------------------------------------
//	This is the main function for your C MSX APP!
//
//	Your fun starts here!!!
//	Replace the code below with your art.
//	Note: Only use argv and argc if you enabled
//	CMDLINE_PARAMETERS on TargetConfig_XXXXX.txt
void initialize (void) {
#if __SDCCCALL
	print("Hello MSX from overlayed C (sdcccall(REGs))!\r\n\0");
#else
	print("Hello MSX from overlayed C (sdcccall(STACK))!\r\n\0");
#endif // __SDCCCALL
}

void finalize(void) {
#if __SDCCCALL
	print("Hello MSX from overlayed C (sdcccall(REGs))!\r\n\0");
#else
	print("Hello MSX from overlayed C (sdcccall(STACK))!\r\n\0");
#endif // __SDCCCALL
}
