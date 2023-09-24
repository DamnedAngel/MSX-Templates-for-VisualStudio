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

#ifdef MDO_SUPPORT
#include "mdointerface.h"
#endif

#ifdef MDO_SUPPORT
//	----------------------------------------------------------
//	This is an example how to use MDOs (overlay modules)
//	Remove it from your application if you're not using overlays.
unsigned char useMDO(void) {
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

	mdoChildHello_hook();		// routine in MDO
	mdoChildGoodbye_hook();		// routine in MDO

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

//	----------------------------------------------------------
//	This is called when an MDO hook is called before it is
//	linked to a child MDO.The application will terminate
//	after the return of this routine.
//	Customize here the finalization of you application.
//  Remove it if you're not using MDOs.
unsigned char onMDOAbend(void) {
	print("Undefined hook called.\r\n\0");
	return 0xa1;	// error code to be relayed to MSX-DOS.
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
	dbg ("Template by Danilo Angelo\r\n");		// only printed in debug mode

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
	if (useMDO()) {
		return 0xa0;
	} else {
		return 0;
	}
#else
	return 0;
#endif

}
