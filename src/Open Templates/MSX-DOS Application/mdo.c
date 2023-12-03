// ----------------------------------------------------------
//		mdo.c - by Danilo Angelo, 2020 - 2023
//
//		MDO support in MSX - DOS program example
//		C version
//
//      This file is only needed when using MDOs
//		and may be ignored otherwise.
// ----------------------------------------------------------

#include "applicationsettings.h"

#ifdef MDO_SUPPORT
// ----------------------------------------------------------
// This is an example how to use MDOs (overlay modules)
// Replace the code below to implement your own MDO.
// ----------------------------------------------------------

#include "mdointerface.h"
#include "printinterface.h"

unsigned char useMDO(void) {
	print("MDO usage example in C.\r\n\0");

	// load MDO
	unsigned char r = mdoLoad(&OVERLAY_ONE);
	if (r) {
		print("Error loading MDO.\r\n\0");
		return r;
	}
	dbg("MDO loaded successfully.\r\n\0");

	// link MDO
	r = mdoLink(&OVERLAY_ONE);
	if (r) {
		print("Error linking MDO.\r\n\0");
		return r;
	}
	dbg("MDO linked successfully.\r\n\0");

	mdoChildHello_hook();		// routine in MDO
	mdoChildGoodbye_hook();		// routine in MDO

	// unlink MDO
	r = mdoUnlink(&OVERLAY_ONE);
	if (r) {
		print("Error unlinking MDO.\r\n\0");
		return r;
	}
	dbg("MDO unlinked successfully.\r\n\0");

	// release MDO
	r = mdoRelease(&OVERLAY_ONE);
	if (r) {
		print("Error releasing MDO.\r\n\0");
		return r;
	}
	dbg("MDO released successfully.\r\n\0");

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