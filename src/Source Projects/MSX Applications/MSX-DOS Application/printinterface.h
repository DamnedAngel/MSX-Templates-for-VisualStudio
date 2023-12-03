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
extern unsigned char* linefeed;

#ifdef DEBUG
extern unsigned char* msgdbg;

// casting below needed for SDCC 4.2.0. Not necessary for 4.3.0.
#define dbg(msg)	do { print ((unsigned char*) &msgdbg); print(msg); } while(0)
#else
#define dbg(msg)	// nothing
#endif

#endif	//  __PRINTINTERFACE_H__
