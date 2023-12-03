// ----------------------------------------------------------
//		devicehandler.c - by Danilo Angelo, 2023
//
//		BASIC's DEVICE handler example
//		C version
//
//      This file is only needed when implementing
//      a new BASIC DEVICE and may be ignored otherwise.
// ----------------------------------------------------------

#include "applicationsettings.h"

#ifdef DEVICE_EXPANSION

#include "printinterface.h"

// ----------------------------------------------------------
//	This is a DEVICE getID handler example.
//	"DEV:"
//
//	PLEASE NOTE THAT SUPPORT FOR DEVICE EXPANSION
//	IS EMBRYONIC AND FAR FROM COMPLETE!
// 
//	This is only for the demo app.
//	To disable the support for BASIC's devices:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's devices from the project:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove / comment all DEVICE items in ApplicationSettings.txt
//	3) Remove all onDeviceXXXXX_getIdand onDeviceXXXXX_IO routines from this file
char onDeviceDEV_getId(void) {
	print("The C handler for DEV_getId says hi!\r\n\0");
	return 0;
}

// ----------------------------------------------------------
//	This is a DEVICE IO handler example.
//	"DEV:"
//
//	PLEASE NOTE THAT SUPPORT FOR DEVICE EXPANSION
//	IS EMBRYONIC AND FAR FROM COMPLETE!
// 
//	This is only for the demo app.
//	To disable the support for BASIC's devices:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	To completely remove the support for BASIC's devices from the project:
//	1) Set DEVICE_EXPANSION to _OFF in ApplicationSettings.txt
//	2) Optionally, remove / comment all DEVICE items in ApplicationSettings.txt
//	3) Remove all onDeviceXXXXX_getIdand onDeviceXXXXX_IO routines from this file
void onDeviceDEV_IO(char cmd, char* param) {
	(void)(cmd + param);	// Does nothing and doesn't generate code. Just prevents the warning for not having used the parameters.

	print("The C handler for DEV_IO says hi!\r\n\0");
}

#endif		// DEVICE_EXPANSION
