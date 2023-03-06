//-------------------------------------------------		
// mdointerface.h created automatically					
// by make.bat												
// on  5:46:30.78 , Mon 03/06/2023 					
//															
// DO NOT BOTHER EDITING THIS.								
// ALL CHANGES WILL BE LOST.								
//-------------------------------------------------		
															
#ifndef  __MDOINTERFACE_H__								
#define  __MDOINTERFACE_H__								
															
#ifdef MDO_SUPPORT											
															
#include "./MSX/MSX-DOS/mdoservices.h"	
extern void mdoChildHello_hook (void) ;						
extern void mdoChildGoodbye_hook (void) ;						
extern unsigned char OVERLAY_ONE;					
															
#endif	// MDO_SUPPORT										
															
#endif	// __MDOINTERFACE_H__								
