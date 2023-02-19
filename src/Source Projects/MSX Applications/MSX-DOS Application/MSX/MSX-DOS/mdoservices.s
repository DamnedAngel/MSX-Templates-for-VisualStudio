;----------------------------------------------------------
;		mdoservices.s - by Danilo Angelo, 2023
;
;		Overlay services for MSX-DOS applications.
;----------------------------------------------------------

.macro MDO_SERVICES
_loadMDO::
	ret

_releaseMDO::
	ret

_abendMDO::
.if __SDCCCALL
    ld      a, #0xff     ; termination code
.else
    ld      l, #0xff     ; termination code
.endif
    jp programEnd
.endm