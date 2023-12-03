;----------------------------------------------------------
;		diskaccess.s - by Danilo Angelo, 2023
;
;		Example of disk access from cartridges.
;
;       This file is only needed when 
;       LATE_EXECUTION is set to _ON.
;
;		ATTENTION: To experience all funcionalities in the
;				  example application in this file:
;			- Set LATE_EXECUTION _ON
;			- Set RETURN_TO_BASIC _OFF
;			- Set FILESTART to 0x8000
;			- Use a floppy interface
;			- Don't plug in a mass storage unit
;----------------------------------------------------------

	.include "MSX/BIOS/msxbios.s"
	.include "targetconfig.s"
	.include "applicationsettings.s"
	.include "printinterface.s"

.if LATE_EXECUTION

FCBinRAM		.equ	0xc100
insertDiskinRAM	.equ	0xc200
spBkp			.equ	0xc300

_saveData::
	ld		a, (#BIOS_H_PHYD)
	cp		#0xC9
	jr nz,	savedata.dskFound

	print	noDiskMsg
	ret

savedata.dskFound::
	print	savingMsg

	; install error handlers
	ld		hl, #insertDisk
	ld		(#BDOS_DSKERR), hl
	ld		(#BDOS_ABORTH), hl

	dbg		errorHandlersMsg

	; Initialize FCB in RAM
	ld		hl, #FCBinRAM
	ld		(#BDOS_DPBBAS), hl
	ex		de, hl
	ld		hl ,#FCB
	ld		bc, #FCB.end - FCB
	ldir	

	dbg		fcbInitialized

	; configure DTA
	ld		de, #myData
	ld		c, #BDOS_SETDTA
	call	BDOS

	dbg		dtaConfigured

	ld		(#spBkp), sp			; Store context in case of errors

savedata.write::
	; create file
	ld		de, #FCBinRAM
	ld		c, #BDOS_FMAKE
	call	BDOS
	or		a
	jp nz,	savedata.error

	dbg		createdMsg

	; write file
	ld		hl, #myData.end - myData
	ld		(#FCBinRAM+14), hl		; record size
	ld		de, #FCBinRAM
	ld		hl, #1
	ld		c, #BDOS_WRBLK
	call	BDOS
	or		a
	jp		nz, savedata.error

	; close file
	ld		de, #FCBinRAM
	ld		c, #BDOS_FCLOSE
	call	BDOS
	or		a
	jp nz,	savedata.error

	print	savedMsg
	ret

savedata.error::
	print	errorMsg
	ret

insertDisk::
	ld		sp, (#spBkp)			; Restore context
	ld		a,c						; Get error flags
	and		#2
	jp z,	savedata.error
	print	#insDiskMsg
	ei

insertDisk.keyLoop:
	ld	a,(#BIOS_NEWKEY + 7)
	bit	#7,a
	jr	nz, insertDisk.keyLoop
	jp	savedata.write
insertDisk.end:

; Data
	.area	_ROMDATA

noDiskMsg:
	.asciz	"No disk installed!\n\r"
savingMsg:
	.asciz	"Saving file 'DATA.DAT'...\n\r"
savedMsg:
	.asciz	"File saved\n\r"
errorMsg:
	.asciz	"File error!!!\n\r"
insDiskMsg:
	.ascii	"Insert the floppy disk\n\r"
	.asciz	"then press RETURN\n\r"

.if DEBUG
errorHandlersMsg:
	.asciz	"Error handlers installed.\n\r"
fcbInitialized:
	.asciz	"FCB initilized.\n\r"
dtaConfigured:
	.asciz	"DTA configured.\n\r"
createdMsg:
	.asciz	"File 'DATA.DAT' created.\n\r"
.endif

FCB:
	.db		#0					; drive_No
	.ascii	"DATA    DAT"		; filename
	.dw		#0					; current_block
	.dw		#0					; record_size
	.dw		#0, #0				; file_size
	.dw		#0					; date
	.dw		#0					; time
	.db		#0					; device_id 
	.db		#0					; directory_location
	.dw		#0					; start_cluster_no
	.dw		#0					; last_access_cluster_no
	.dw		#0					; cluster_offset
	.db		#0					; current_record
	.dw		#0, #0				; random_record
FCB.end:

myData:
	.asciz "Hi. This is the data to be saved!"
myData.end:

.endif	; LATE_EXECUTION
