//----------------------------------------------------------
//		mdoservices.h - by Danilo Angelo 2023
//
//		Overlay services for MSX-DOS applications.
//----------------------------------------------------------

#ifndef  __MDOSERVICES_H__
#define  __MDOSERVICES_H__

unsigned char mdoLoad(unsigned char*);
unsigned char mdoRelease(unsigned char*);
unsigned char mdoLink(unsigned char*);
unsigned char mdoUnlink(unsigned char*);

#endif  // __MDOSERVICES_H__