//-------------------------------------------------		
// mdointerface.h created automatically					
// by make.bat												
// on  8:29:48.92 , Sun 09/17/2023 					
//															
// DO NOT BOTHER EDITING THIS.								
// ALL CHANGES WILL BE LOST.								
//-------------------------------------------------		
															
#ifndef  __MDOINTERFACE_H__								
#define  __MDOINTERFACE_H__								
															
#ifdef MDO_SUPPORT											
															
extern unsigned char mdoLoad(unsigned char*);				
extern unsigned char mdoRelease(unsigned char*);			
extern unsigned char mdoLink(unsigned char*);				
extern unsigned char mdoUnlink(unsigned char*);			
															
extern void mdoChildHello_hook (void) ;				
extern void mdoChildGoodbye_hook (void) ;				
extern unsigned char OVERLAY_ONE;					
															
#endif	// MDO_SUPPORT										
															
#endif	// __MDOINTERFACE_H__								
															
