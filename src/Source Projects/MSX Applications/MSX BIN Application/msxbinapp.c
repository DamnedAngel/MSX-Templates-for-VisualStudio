// ----------------------------------------------------------
//		msxbinapp.c - by Danilo Angelo, 2020-2023
//
//		BIN program(BLOAD'able) for MSX example
//		C version
// ----------------------------------------------------------

#include "targetconfig.h"
#include "MSX/BIOS/msxbios.h"

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

_printMSG_loop:
	ld		a, (hl); print
	or		a
	ret z
	call	0x00a2; BIOS_CHPUT
	inc		hl
	jr		_printMSG_loop
__endasm;
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
//	This is an example of a C routine accessible by
//	BASIC USR calls.
//	Please also check the reference to the routine in 
//	ApplicationSettings.txt file.
//	This is only for the demo app.
//	You can safely remove it for your application.
void printFromBasic(void) {
	unsigned int addr = (*((volatile unsigned int*)(BIOS_USRDATA)));
	print((char*)addr);
	return;
}

// ----------------------------------------------------------
//	This is the main function for your C MSX APP!
//
//	Your fun starts here!!!
//	Replace the code below with your art.
void main(void) {
#if __SDCCCALL
	print("Hello MSX from C (sdcccall(REGs))!\r\n\0");
#else
	print("Hello MSX from C (sdcccall(STACK))!\r\n\0");
#endif // __SDCCCALL
	return;
}
