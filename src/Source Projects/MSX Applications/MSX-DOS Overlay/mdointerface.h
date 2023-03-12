//-------------------------------------------------		
// mdointerface.h created automatically					
// by make.bat												
// on 20:11:21.04 , Sun 03/12/2023 					
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
															
															
#endif	// MDO_SUPPORT										
															
#endif	// __MDOINTERFACE_H__								
															
