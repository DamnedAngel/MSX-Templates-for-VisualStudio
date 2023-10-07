#pragma once
// ----------------------------------------------------------
//		printinterface.h - by Danilo Angelo, 2023
//
//		Interface for print and debug functionalities.
// ----------------------------------------------------------

#ifndef  __PRINTINTERFACE_H__							
#define  __PRINTINTERFACE_H__	

#include "targetconfig.h"

extern void print(unsigned char*);

#ifdef DEBUG
extern unsigned char* msgdbg;
#define dbg(msg)	print (&msgdbg); print(msg);
#else
#define dbg(msg)	// nothing
#endif

#endif	//  __PRINTINTERFACE_H__