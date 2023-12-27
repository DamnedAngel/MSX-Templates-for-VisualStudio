;----------------------------------------------------------
;		vdpportmacro.s - by Danilo Angelo, 2023
;
;		VDP to map all VDP ports in the program.
;----------------------------------------------------------

;----------------------------------------------------------
;	out (#vdpPort), a
;----------------------------------------------------------
.macro vdp_OutA vdpPort, locLabel, ?count
	.area	_VDPOUTPORTMAP
	.db		#vdpPort
	.dw		#vdpPort_'locLabel'_'count + #1

	.area	_CODE
vdpPort_'locLabel'_'count::
	out		(#0x98 + #vdpPort), a
.endm

;----------------------------------------------------------
;	in	a, (#vdpPort)
;----------------------------------------------------------
.macro vdp_InA vdpPort, locLabel, ?count
	.area	_VDPINPORTMAP
	.db		#vdpPort
	.dw		#vdpPort_'locLabel'_'count + #1

	.area	_CODE
vdpPort_'locLabel'_'count::
	in		a, (#0x98 + #vdpPort)
.endm

;----------------------------------------------------------
;	ld c, #vdpOutPort
;----------------------------------------------------------
.macro ld_c_vdpOutPort vdpPort, locLabel, ?count
	.area	_VDPOUTPORTMAP
	.db		#vdpPort
	.dw		#vdpPort_'locLabel'_'count + #1

	.area	_CODE
vdpPort_'locLabel'_'count::
	ld		c, #0x98 + #vdpPort
.endm

;----------------------------------------------------------
;	ld c, #vdpInPort
;----------------------------------------------------------
.macro ld_c_vdpInPort vdpPort, locLabel, ?count
	.area	_VDPINPORTMAP
	.db		#vdpPort
	.dw		#vdpPort_'locLabel'_'count + #1

	.area	_CODE
vdpPort_'locLabel'_'count::
	ld		c, #0x98 + #vdpPort
.endm
