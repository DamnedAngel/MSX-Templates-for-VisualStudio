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
//	This is the custom initialization function for your C MDO.
//	Invoked when the MDO is loaded.
void initialize (void) {
#if __SDCCCALL
	print("MDO in C (sdcccall(REGs)) initialized!\r\n\0");
#else
	print("MDO in C (sdcccall(STACK)) initialized!\r\n\0");
#endif // __SDCCCALL
}

// ----------------------------------------------------------
//	This is the custom finalization function for your C MDO!
//	Invoked when the MDO is unloaded.
void finalize(void) {
	print("MDO finalized!\r\n\0");
}

// ----------------------------------------------------------
//	This is the custom activation function for your C MDO!
//	Invoked when the MDO is linked.
void activate(void) {
	print("MDO activated!\r\n\0");
}

// ----------------------------------------------------------
//	This is the custom deactivation function for your C MDO!
//	Invoked when the MDO is inlinked.
void deactivate(void) {
	print("MDO deactivated!\r\n\0");
}

// ----------------------------------------------------------
//	These are examples of dinamically linked function
//  which may be called by parent module
void hello(void) {
	print("Hello MSX from dinamically linked function!\r\n\0");
}

void goodbye(void) {
	print("Goodbye MSX from dinamically linked function!\r\n\0");
}
