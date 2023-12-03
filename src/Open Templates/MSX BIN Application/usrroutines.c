// ----------------------------------------------------------
//		usrroutines.c - by Danilo Angelo, 2023
//
//		Example od routines to be called by
//      BASIC's USR() function
//		C version
// ----------------------------------------------------------

#include "MSX/BIOS/msxbios.h"
#include "targetconfig.h"
#include "printinterface.h"

// ----------------------------------------------------------
//	This is an example of a C routine accessible by
//	BASIC USR calls.
//	Please also check the reference to the routine in 
//	ApplicationSettings.txt file.
void printFromBasic(void) {
	dbg("C version of _printFromBasic called!\r\n");
	unsigned int addr = (*((volatile unsigned int*)(BIOS_USRDATA)));
	print((char*)addr);
	return;
}
