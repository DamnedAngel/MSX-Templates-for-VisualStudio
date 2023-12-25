// ----------------------------------------------------------
//		mdostructures.h - by DamnedAngel, 2023
//
//		MDO structures
// ----------------------------------------------------------

#ifndef  __MDOSTRUCTURES_H__
#define  __MDOSTRUCTURES_H__

#define     mdoStatus_loaded    0b00000001
#define     mdoStatus_linked    0b00000010

typedef struct {
    unsigned char status;
    char fileName[8];
    char extension[3];
    unsigned int address;
    unsigned char mdoName;
} mdoHandler;

#endif	// __MDOSTRUCTURES_H__
