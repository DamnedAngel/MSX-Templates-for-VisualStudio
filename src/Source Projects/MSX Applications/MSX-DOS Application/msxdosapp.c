// ----------------------------------------------------------
//		msxbinapp.c - by Danilo Angelo, 2020-2023
//
//		BIN program(BLOAD'able) for MSX example
//		C version
// ----------------------------------------------------------

#include "MSX/BIOS/msxbios.h"
#include "targetconfig.h"
#include "applicationsettings.h"

#ifdef MDO_SUPPORT
#include "mdointerface.h"
#endif

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

//	----------------------------------------------------------
//	This is an example how to use MDOs (overlay modules)
//	Remove it from your application if you're not using overlays.
#ifdef MDO_SUPPORT
unsigned char useMDO() {
	unsigned char r = mdoLoad(&OVERLAY_ONE);
	if (r) {
		print("Error loading MDO.\r\n\0");
		return r;
	}
	print("MDO loaded successfully.\r\n\0");

	r = mdoLink(&OVERLAY_ONE);
	if (r) {
		print("Error linking MDO.\r\n\0");
		return r;
	}
	print("MDO linked successfully.\r\n\0");

	mdoChildHello_hook();

	mdoChildGoodbye_hook();

	r = mdoUnlink(&OVERLAY_ONE);
	if (r) {
		print("Error unlinking MDO.\r\n\0");
		return r;
	}
	print("MDO unlinked successfully.\r\n\0");

	r = mdoRelease(&OVERLAY_ONE);
	if (r) {
		print("Error releasing MDO.\r\n\0");
		return r;
	}
	print("MDO released successfully.\r\n\0");

	return 0;
}
#endif

// ----------------------------------------------------------
//	This is the main function for your C MSX APP!
//
//	Your fun starts here!!!
//	Replace the code below with your art.
//	Note: Only use argv and argc if you enabled
//	CMDLINE_PARAMETERS on TargetConfig_XXXXX.txt
unsigned char main(char** argv, int argc) {
#if __SDCCCALL
	print("Hello MSX from C (sdcccall(REGs))!\r\n\0");
#else
	print("Hello MSX from C (sdcccall(STACK))!\r\n\0");
#endif // __SDCCCALL

#ifdef CMDLINE_PARAMETERS
	print("Parameters:\r\n\0");
	for (int i = 0; i < argc; i++) {
		print(argv[i]);
		_print("\r\n\0");
	}
#endif

#ifdef MDO_SUPPORT
	return useMDO();
#else
	return 0;
#endif

}
