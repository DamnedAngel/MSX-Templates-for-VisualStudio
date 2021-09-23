// ----------------------------------------------------------
//		msxromapp.c - by Danilo Angelo, 2020
//
//		ROM program(cartridge) for MSX example
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
		ld      hl, #2; retrieve address from stack
		add     hl, sp
		ld		b, (hl)
		inc		hl
		ld		h, (hl)
		ld		l, b

		_printMSG_loop :
		ld		a, (hl); print
		or		a
		ret z
		push	hl
		push	ix
		ld		iy, (#0xfcc0); BIOS_ROMSLT
		ld		ix, #0x00a2; BIOS_CHPUT
		call	#0x001c; BIOS_CALSLT
		pop		ix
		pop		hl
		inc		hl
		jr		_printMSG_loop
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
void main(void) {
	print("Hello MSX from C!\r\n"
		"If you don't want your\r\n"
		"ROM program to return to\r\n"
		"BASIC/MSX-DOS, just avoid\r\n"
		"main's return instruction.\r\n\0");
}

// ----------------------------------------------------------
//	This is a parameterized CALL handler example.
//	CALL CMD1 (<STRING>)
//	return	0: Success; anything else: syntax error
//
//	This is only for the demo app.
//	To disable the support for BASIC's CALL statement:
//	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's CALL statement from the project:
//	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
//	3) Remove all onCallXXXXX functions from this file
unsigned char onCallCMD1(char** param) {
	char buffer[255];
	int i = 1;

	if (**param != '(') {
		return -1;
	}
	(*param)++;
	while (**param == ' ') {
		(*param)++;
	}
	if (**param != '"') {
		return -1;
	}
	(*param)++;
	buffer[0] = '"';
	while (**param != '"') {
		buffer[i++] = *((*param)++);
	}
	buffer[i++] = '"';
	buffer[i] = 0;
	(*param)++;
	while (**param == ' ') {
		(*param)++;
	}
	if (**param != ')') {
		return -1;
	}
	(*param)++;

	// seek end of command (0x00/EoL ou 0x3a/":")
	while (**param == ' ') {
		(*param)++;
	}
	if ((**param != 0) && (**param != 0x3a)) {
		return -1;
	}

	print("The C handler for CMD1 says: \0");
	print(buffer);
	print("!\r\n\0");
	return 0;
}

// ----------------------------------------------------------
//	This is a parameterless CALL handler example.
//	CALL CMD2
//	return	0: Success; anything else: syntax error
// 
//	This is only for the demo app.
//	To disable the support for BASIC's CALL statement:
//	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's CALL statement from the project:
//	1) Set CALL_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove/comment all CALL_STATEMENT items in ApplicationSettings.txt
//	3) Remove all onCallXXXXX functions from this file
unsigned char onCallCMD2(char** param) {
	// check no parameters (next char must be 0x00/EoL ou 0x3a/":")
	if ((**param != 0) && (**param != 0x3a)) {
		return -1;
	}

	print("The C handler for CMD2 says hi!\r\n\0");
	return 0;
}

// ----------------------------------------------------------
//	This is a DEVICE getID handler example.
//	"DEV:"
//
//	This is only for the demo app.
//	To disable the support for BASIC's devices:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's devices from the project:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove / comment all DEVICE items in ApplicationSettings.txt
//	3) Remove all onDeviceXXXXX_getIdand onDeviceXXXXX_IO routines from this file
char onDeviceDEV_getId() {
	print("The C handler for DEV_getId says hi!\r\n\0");
	return 0;
}

// ----------------------------------------------------------
//	This is a DEVICE IO handler example.
//	"DEV:"
//
//	This is only for the demo app.
//	To disable the support for BASIC's devices:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's devices from the project:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove / comment all DEVICE items in ApplicationSettings.txt
//	3) Remove all onDeviceXXXXX_getIdand onDeviceXXXXX_IO routines from this file
void onDeviceDEV_IO(char* param, char cmd) {
	print("The C handler for DEV_IO says hi!\r\n\0");
}

