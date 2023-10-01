// ----------------------------------------------------------
//		msxromapp.c - by Danilo Angelo, 2020-2023
//
//		ROM program(cartridge) for MSX example
//		C version
// ----------------------------------------------------------

#include "MSX/BIOS/msxbios.h"
#include "targetconfig.h"
#include "applicationsettings.h"
#include "printinterface.h"

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
	print("If you don't want your\r\n"
		"ROM program to return to\r\n"
		"BASIC/MSX-DOS, just avoid\r\n"
		"main's return instruction.\r\n\0");
	dbg("Template by Danilo Angelo\r\n\0");		// only printed in debug mode
}

