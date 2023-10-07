// ----------------------------------------------------------
//		msxbinapp.c - by Danilo Angelo, 2020-2023
//
//		BIN program(BLOAD'able) for MSX example
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
// 
//  Note 1: You only need conditional code based
//	on __SDCCCALL if youplan to support both
//	calling convention.
// 
//	Note 2: Only use argv and argc if you enabled
//	CMDLINE_PARAMETERS on TargetConfig_XXXXX.txt
unsigned char main(char** argv, int argc) {
#if __SDCCCALL
	print("Hello MSX from C (sdcccall(REGs))!\r\n\0");
#else
	print("Hello MSX from C (sdcccall(STACK))!\r\n\0");
#endif // __SDCCCALL
	dbg("Template by Danilo Angelo\r\n\0");		// only printed in debug mode

#ifdef CMDLINE_PARAMETERS
	print("Parameters:\r\n\0");
	for (int i = 0; i < argc; i++) {
		print(argv[i]);
		print("\r\n\0");
	}
#endif

#ifdef MDO_SUPPORT
//	useMDO returns errorcode, but in this
//  example we will ignore it and return
//	#0xa0 error code for all MDO errors.
//  Remove it if you're not using MDOs.
extern unsigned char useMDO(void);
	if (useMDO()) {
		return 0xa0;
	} else {
		return 0;
	}
#else
	return 0;
#endif
}

