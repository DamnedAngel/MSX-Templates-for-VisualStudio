@echo off

REM -----------------------------------------------------------------------------------
set OPEN1=MSX SDCC Make Script Copyright © 2020-2021 Danilo Angelo, 2021 Pedro Medeiros
set OPEN2=version 00.05.00 - Codename Mac\'n\'Tux
REM -----------------------------------------------------------------------------------

set CURRENT_DIR=%CD%
set MSX_BUILD_TIME=%TIME% 
set MSX_BUILD_DATE=%DATE% 

SETLOCAL ENABLEDELAYEDEXPANSION

set MSX_FILE_NAME=MSXAPP
set PROFILE=%1
set MSX_OBJ_PATH=%PROFILE%\objs
set MSX_BIN_PATH=%PROFILE%\bin
set MSX_DEV_PATH=..\..\..
set MSX_LIB_PATH=%MSX_DEV_PATH%\libs

set OBJLIST=
set INCDIRS=

set BIN_SIZE=
set FILE_START=0x0100
set CODE_LOC=
set DATA_LOC=0
set PARAM_HANDLING_ROUTINE=0

set DBG_MUTE=0
set DBG_ERROR=10
set DBG_OPENING=40
set DBG_STEPS=50
set DBG_SETTING=70
set DBG_OUTPUT=100
set DBG_DETAIL=120
set DBG_CALL1=150
set DBG_CALL2=160
set DBG_CALL3=170
set DBG_EXTROVERT=200
set DBG_PARAMS=230
set DBG_VERBOSE=255
set BUILD_DEBUG=%DBG_CALL2%

goto :orchestration

#
# Helper Functions
#

:replace_string
	set VALUE=!VALUE:%SEARCH_STR%=%REPLACE_STR%!
	exit /B

:debug
	if %1 GTR %BUILD_DEBUG% exit /B
	set MSG=%2
	:debug_loop
	if "%3"=="" goto :debug_msg
	set MSG=%MSG% %3
	shift
	goto :debug_loop

	:debug_msg
	echo %MSG%
	exit /B

:exec
	set DBG=%1
	set CMD_LINE=%2
	:exec_loop
	if "%3"=="" goto :exec_cont1
	set CMD_LINE=%CMD_LINE% %3
	shift
	goto :exec_loop

	:exec_cont1
	call :debug %DBG% ## %CMD_LINE%
	if %DBG_PARAMS% LEQ %BUILD_DEBUG% (
		set i=1
		rem EVIL FORMATTING IN THE FOLLOWING 3 LINES. DO NOT CHANGE ANYTHING, NOT EVEN SPACES OR IDENTATION
		set ^"CMD_LINE2=!CMD_LINE: =^

!"
		for /f "eol=: delims=" %%S in ("!CMD_LINE2!") do (
		  echo ARG[!i!]=%%S
		  set /a i=!i!+1
		)
	)
 	cmd /c %CMD_LINE% > OUTPUT.TMP
	set ERR=%ERRORLEVEL%
	if "%ERR%"=="0" goto :exec_cont2
	type OUTPUT.TMP
    call :debug %DBG_ERROR% ### Error %ERR% executing
    call :debug %DBG_ERROR% ### %CMD_LINE%
	del OUTPUT.TMP
	exit %ERR%

	:exec_cont2
	if %DBG_OUTPUT% LEQ %BUILD_DEBUG% (
		type OUTPUT.TMP
	)
	del OUTPUT.TMP
	exit /B

:create_dir
	set NEW_PATH=%1
	set ACC_PATH=.
	:create_dir_loop
	FOR /F "tokens=1* delims=\" %%A IN ("%NEW_PATH%") DO (
		set SINGLE_DIR=%%A
		set "SINGLE_DIR_B=!SINGLE_DIR::=!"
		if "!SINGLE_DIR!"=="!SINGLE_DIR_B!" (
			set ACC_PATH=!ACC_PATH!\!SINGLE_DIR!
			if not exist "!ACC_PATH!" (
				mkdir !ACC_PATH!
			)
		) else (
			set ACC_PATH=!SINGLE_DIR!
		)
		set NEW_PATH=%%B
	)
	if defined NEW_PATH goto :create_dir_loop
	exit /B

:create_dir_struct
	if NOT EXIST "%MSX_OBJ_PATH%" (
		echo -------------------------------------------------------------------------------
		echo Creating OBJ path...
		call :create_dir %MSX_OBJ_PATH%
		echo Done creating OBJ path.
	)
	if NOT EXIST "%MSX_BIN_PATH%" (
		echo -------------------------------------------------------------------------------
		echo Creating BIN path...
		call :create_dir %MSX_BIN_PATH%
		echo Done creating BIN path.
	)
	exit /B


#
# Build phases
#

:configure_target
	echo -------------------------------------------------------------------------------
	echo Building target configuration files...
	echo //-------------------------------------------------	>  TargetConfig.h
	echo // targetconfig.h created automatically by make.bat	>> TargetConfig.h
	echo // on %MSX_BUILD_TIME%, %MSX_BUILD_DATE%				>> TargetConfig.h
	echo //														>> TargetConfig.h
	echo // DO NOT BOTHER EDITING THIS.							>> TargetConfig.h
	echo // ALL CHANGES WILL BE LOST.							>> TargetConfig.h
	echo //-------------------------------------------------	>> TargetConfig.h
	echo.														>> TargetConfig.h
	echo #ifndef  __TARGETCONFIG_H__							>> TargetConfig.h
	echo #define  __TARGETCONFIG_H__							>> TargetConfig.h
	echo.														>> TargetConfig.h

	echo ;-------------------------------------------------		>  TargetConfig.s
	echo ; targetconfig.s created automatically by make.bat		>> TargetConfig.s
	echo ; on %MSX_BUILD_TIME%, %MSX_BUILD_DATE%				>> TargetConfig.s
	echo ;														>> TargetConfig.s
	echo ; DO NOT BOTHER EDITING THIS.							>> TargetConfig.s
	echo ; ALL CHANGES WILL BE LOST.							>> TargetConfig.s
	echo ;-------------------------------------------------		>> TargetConfig.s
	echo.														>> TargetConfig.s

	for /F "tokens=1,2" %%A in  (TargetConfig_%PROFILE%.txt) do  (
		set TAG=%%A
		set TAG1=!TAG:~0,1!
		if NOT "!TAG1!" == ";" (
			if "!TAG1!" == "." (
				set TARGET_SECTION=!TAG!
			) else if /I "!TARGET_SECTION!"==".COMPILE" (
				if /I "%%A"=="BUILD_DEBUG" (
					REM configure compile level debug
					set BUILD_DEBUG=%%B
				) else (
					if /I "%%B"=="_off" (
						echo //#define %%A						>> targetconfig.h
						echo %%A = 0							>> targetconfig.s
					) else if /I "%%B"=="_on" (
						echo #define %%A						>> targetconfig.h
						echo %%A = 1							>> targetconfig.s
					) else if /I "%%B"=="" (
						echo #define %%A 						>> targetconfig.h
						echo %%A = 1							>> targetconfig.s
					) else (
						echo #define %%A %%B					>> targetconfig.h
						echo %%A = %%B							>> targetconfig.s
					)
				)
			) else if /I "!TARGET_SECTION!"==".FILESYSTEM" (
				set VALUE=%%B

				rem replaces PROFILE
				set SEARCH_STR=[PROFILE]
				set REPLACE_STR=!PROFILE!
				call :replace_string
			
				rem replaces MSX_FILE_NAME 
				set SEARCH_STR=[MSX_FILE_NAME]
				set REPLACE_STR=!MSX_FILE_NAME!
				call :replace_string

				rem replaces MSX_FILE_EXTENSION
				set SEARCH_STR=[MSX_FILE_EXTENSION]
				set REPLACE_STR=!MSX_FILE_EXTENSION!
				call :replace_string

				rem replaces MSX_DEV_PATH
				set SEARCH_STR=[MSX_DEV_PATH]
				set REPLACE_STR=!MSX_DEV_PATH!
				call :replace_string

				rem replaces MSX_OBJ_PATH
				set SEARCH_STR=[MSX_OBJ_PATH]
				set REPLACE_STR=!MSX_OBJ_PATH!
				call :replace_string
			
				rem replaces MSX_BIN_PATH
				set SEARCH_STR=[MSX_BIN_PATH]
				set REPLACE_STR=!MSX_BIN_PATH!
				call :replace_string
			
				rem replaces MSX_LIB_PATH
				set SEARCH_STR=[MSX_LIB_PATH]
				set REPLACE_STR=!MSX_LIB_PATH!
				call :replace_string
			
				set %%A=!VALUE!
				if "!VALUE!"=="" echo ### Warning: variable %%A erased.
			)
		)
	)

	echo.														>> TargetConfig.h
	echo #endif	//  __TARGETCONFIG_H__							>> TargetConfig.h
	exit /B

:opening
	call :debug %DBG_OPENING% -------------------------------------------------------------------------------
	call :debug %DBG_OPENING% %OPEN1%
	call :debug %DBG_OPENING% %OPEN2%
	call :debug %DBG_SETTING% Build Debug Level %BUILD_DEBUG%
	exit /B

:filesystem_settings
    call :debug %DBG_SETTING% -------------------------------------------------------------------------------
    call :debug %DBG_SETTING% Filesystem config...
    call :debug %DBG_SETTING% Current dir=%CURRENT_DIR%
    call :debug %DBG_SETTING% Target file=.\%MSX_FILE_NAME%.%MSX_FILE_EXTENSION%
    call :debug %DBG_SETTING% Object path=.\%MSX_OBJ_PATH%
    call :debug %DBG_SETTING% Binary path=.\%MSX_BIN_PATH%
    call :debug %DBG_SETTING% MSX dev path=.\%MSX_DEV_PATH%
    call :debug %DBG_SETTING% MSX lib path=.\%MSX_LIB_PATH%
	exit /B

:house_cleaning
    call :debug %DBG_STEPS% -------------------------------------------------------------------------------
    call :debug %DBG_STEPS% Making a small housecleaning.
	if EXIST %MSX_OBJ_PATH%\bin_usrcalls.tmp del %MSX_OBJ_PATH%\bin_usrcalls.tmp
	if EXIST %MSX_OBJ_PATH%\rom_callexpansionindex.tmp del %MSX_OBJ_PATH%\rom_callexpansionindex.tmp
	if EXIST %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp del %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
	if EXIST %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp del %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp
	if EXIST %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp del %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
    call :debug %DBG_STEPS% Done housecleaning.
	exit /B

:application_settings
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Building application settings file...
	echo ;-------------------------------------------------		>  applicationsettings.s
	echo ; applicationsettings.s created automatically			>> applicationsettings.s
	echo ; by make.bat											>> applicationsettings.s
	echo ; on %MSX_BUILD_TIME%, %MSX_BUILD_DATE%				>> applicationsettings.s
	echo ;														>> applicationsettings.s
	echo ; DO NOT BOTHER EDITING THIS.							>> applicationsettings.s
	echo ; ALL CHANGES WILL BE LOST.							>> applicationsettings.s
	echo ;-------------------------------------------------		>> applicationsettings.s
	echo.														>> applicationsettings.s

	for /F "tokens=1,2" %%A in  (ApplicationSettings.txt) do  (
		set TAG=%%A
		if NOT "!TAG:~0,1!"==";" (
			if /I ".!TAG!"==".PROJECT_TYPE" (
				set PROJECT_TYPE=%%B
			) else if /I ".!TAG!"==".FILESTART" (
				echo fileStart .equ %%B							>> applicationsettings.s
				set FILE_START=%%B
			) else if /I ".!TAG!"==".ROM_SIZE" (
				if /I "%%B"=="16k" (
					set BIN_SIZE=4000
				) else (
					set BIN_SIZE=8000
				)
			) else if /I ".!TAG!"==".CODE_LOC" (
				set CODE_LOC=%%B
			) else if /I ".!TAG!"==".DATA_LOC" (
				set DATA_LOC=%%B
			) else if /I ".!TAG!"==".PARAM_HANDLING_ROUTINE" (
				echo paramHandlingRoutine .equ %%B				>> applicationsettings.s
				echo PARAM_HANDLING_ROUTINE = %%B				>> applicationsettings.s
			) else if /I ".!TAG!"==".SYMBOL" (
				IF NOT EXIST %MSX_OBJ_PATH%\bin_usrcalls.tmp (
					echo.										>> %MSX_OBJ_PATH%\bin_usrcalls.tmp
				)
				echo .globl %%B									>> %MSX_OBJ_PATH%\bin_usrcalls.tmp
				echo .dw %%B									>> %MSX_OBJ_PATH%\bin_usrcalls.tmp
			) else if /I ".!TAG!"==".ADDRESS" (
				IF NOT EXIST %MSX_OBJ_PATH%\bin_usrcalls.tmp (
					echo.										>> %MSX_OBJ_PATH%\bin_usrcalls.tmp
				)
				echo .dw %%B									>> %MSX_OBJ_PATH%\bin_usrcalls.tmp
			) else if /I ".!TAG!"==".CALL_STATEMENT" (
 				IF NOT EXIST %MSX_OBJ_PATH%\rom_callexpansionindex.tmp (
					echo callStatementIndex::					>> %MSX_OBJ_PATH%\rom_callexpansionindex.tmp
				)
				echo .dw		callStatement_%%B				>> %MSX_OBJ_PATH%\rom_callexpansionindex.tmp
				echo .globl		_onCall%%B						>> %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
				echo callStatement_%%B::						>> %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
				echo .ascii		'%%B\0'							>> %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
				echo .dw		_onCall%%B						>> %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
			) else if /I ".!TAG!"==".DEVICE" (
 				IF NOT EXIST %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp (
					echo deviceIndex::							>> %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp
				)
				echo .dw		device_%%B						>> %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp
				echo .globl		_onDevice%%B_IO					>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
				echo .globl		_onDevice%%B_getId				>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
				echo device_%%B::								>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
				echo .ascii		'%%B\0'							>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
				echo .dw		_onDevice%%B_IO					>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
				echo .dw		_onDevice%%B_getId				>> %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
			) else (
				if /I "%%B"=="_off" (
					echo %%A = 0								>> applicationsettings.s
				) else if /I "%%B"=="_on" (
					echo %%A = 1								>> applicationsettings.s
				) else if /I "%%B"=="" (
					echo %%A = 1								>> applicationsettings.s
				) else (
					echo %%A = %%B								>> applicationsettings.s
				)
			)
		)
	)

	if /I ".!PROJECT_TYPE!"==".BIN" (
		echo Adding specific BIN settings...
		echo .macro MCR_USRCALLSINDEX							>> applicationsettings.s
		IF EXIST %MSX_OBJ_PATH%\bin_usrcalls.tmp (
			echo.												>> applicationsettings.s
			echo _BASIC_USR_INDEX::								>> applicationsettings.s
			type %MSX_OBJ_PATH%\bin_usrcalls.tmp				>> applicationsettings.s
			del %MSX_OBJ_PATH%\bin_usrcalls.tmp
		)
		echo .endm												>> applicationsettings.s
	)

	if /I ".!PROJECT_TYPE!"==".ROM" (
		echo Adding specific ROM settings...
		echo.													>> applicationsettings.s
		echo .macro MCR_CALLEXPANSIONINDEX						>> applicationsettings.s
		IF EXIST %MSX_OBJ_PATH%\rom_callexpansionindex.tmp (
			type %MSX_OBJ_PATH%\rom_callexpansionindex.tmp		>> applicationsettings.s
			echo .dw	#0										>> applicationsettings.s
 			type %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp	>> applicationsettings.s
			del %MSX_OBJ_PATH%\rom_callexpansionindex.tmp
			del %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
		)
		echo .endm												>> applicationsettings.s

		echo.													>> applicationsettings.s
		echo .macro MCR_DEVICEEXPANSIONINDEX					>> applicationsettings.s
		IF EXIST %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp (
			type %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp	>> applicationsettings.s
			echo .dw	#0										>> applicationsettings.s
 			type %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp	>> applicationsettings.s
			del %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp
			del %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp
		)
		echo .endm												>> applicationsettings.s
	)

    call :debug %DBG_STEPS% Done building application settings file.
	exit /B

:clean 
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Cleaning...
	if EXIST %MSX_OBJ_PATH%\*.* call :exec %DBG_EXTROVERT% del %MSX_OBJ_PATH%\*.* /F /Q
	if EXIST %MSX_BIN_PATH%\%MSX_FILE_NAME%.%MSX_FILE_EXTENSION% call :exec %DBG_EXTROVERT% del %MSX_BIN_PATH%\%MSX_FILE_NAME%.%MSX_FILE_EXTENSION%
	call :debug %DBG_STEPS% Done cleaning.
	exit /B

:collect_include_dirs
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Collecting include cirectories...
	for /F "tokens=*" %%A in (IncludeDirectories.txt) do (
		set INCDIR=%%A
		if NOT "%INCDIR:~0,1%"==";" (
			set INCDIR=!INCDIR:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set INCDIR=!INCDIR:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set INCDIRS=!INCDIRS! -I"!INCDIR!"
			call :debug %DBG_DETAIL% Collected !INCDIR!
		)
	)
	call :debug %DBG_STEPS% Done collecting include directories.
	exit /B

:build_lib
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Building libraries...
	for /F "tokens=*" %%A in (LibrarySources.txt) do (
		set LIBFILE=%%A
		if NOT "%LIBFILE:~0,1%"==";" (
			set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
			if /I "%%~xA"==".c" (
				call :debug %DBG_DETAIL% Processing C file !LIBFILE!... 
				call :exec %DBG_CALL3% sdcc -mz80 -c %INCDIRS% -o "!RELFILE!" "!LIBFILE!"
			) else (
				call :debug %DBG_DETAIL% Processing ASM file !LIBFILE!... 
				call :exec %DBG_CALL3% sdasz80 -o "!RELFILE!" "!LIBFILE!"
			)
		)
	)
	call :debug %DBG_STEPS% Done building libraries.
	exit /B

:compile
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Building application modules...
	for /F "tokens=1" %%A in  (ApplicationSources.txt) do  (
		set APPFILE=%%A
		if NOT "%APPFILE:~0,1%"==";" (
			set APPFILE=!APPFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set APPFILE=!APPFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
			if /I "%%~xA"==".c" (
				call :debug %DBG_DETAIL% Processing C file !APPFILE!... 
				call :exec %DBG_CALL3% sdcc -mz80 -c %INCDIRS% -o "!RELFILE!" "!APPFILE!"
			) else (
				call :debug %DBG_DETAIL% Processing ASM file !APPFILE!... 
				call :exec %DBG_CALL3% sdasz80 -o "!RELFILE!" "!APPFILE!"
			)
			set OBJLIST=!OBJLIST! "!RELFILE!"
		)
	)
	call :debug %DBG_STEPS% Done building application modules.

	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Collecting libraries...
	for /F "tokens=*" %%A in (LibrarySources.txt) do (
		set LIBFILE=%%A
		if NOT "%LIBFILE:~0,1%"==";" (
			set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
			set OBJLIST=!OBJLIST! "!RELFILE!"
			call :debug %DBG_DETAIL% Collected !RELFILE!
		)
	)
	for /F "tokens=*" %%A in (Libraries.txt) do (
		set LIBFILE=%%A
		if NOT "%LIBFILE:~0,1%"==";" (
			set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set OBJLIST=!OBJLIST! "!LIBFILE!"
			call :debug %DBG_DETAIL% Collected !LIBFILE!
		)
	)
	call :debug %DBG_STEPS% Done collecting libraries.

	IF "%CODE_LOC%"=="" (
		call :debug %DBG_STEPS% -------------------------------------------------------------------------------
		call :debug %DBG_STEPS% Determining CODE-LOC...
		for %%f IN (%MSX_OBJ_PATH%\msx*crt0.rel) DO (
			call :debug %DBG_OUTPUT% Analyzing %%f...
			for /F "tokens=2,4" %%A in  (%%f) do  (
				if "x%%A"=="x_HEADER0" (
					set /A DEC_HEADER_SIZE=0x%%B
					set /A DEC_CODE_LOC=%FILE_START%+!DEC_HEADER_SIZE!
					call cmd /c exit /b !DEC_HEADER_SIZE!
					set HEADER_SIZE=0x!=exitcode!
					call cmd /c exit /b !DEC_CODE_LOC!
					set CODE_LOC=0x!=exitcode!
				)
			)
		)
		call :debug %DBG_OUTPUT% FILE_START is %FILE_START%.
		call :debug %DBG_OUTPUT% _HEADER segment size is !HEADER_SIZE!.
		call :debug %DBG_OUTPUT% CODE-LOC determined to be !CODE_LOC!.
	)

	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Compiling...
	call :exec %DBG_CALL1% sdcc --code-loc %CODE_LOC% --data-loc %DATA_LOC% -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 %OBJLIST% %INCDIRS% -o "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
	call :debug %DBG_STEPS% Done compiling.
	exit /B

:build_msx_bin
	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Build MSX binary...
	if ".%BIN_SIZE%"=="." (
		call :exec %DBG_CALL2% hex2bin -e %MSX_FILE_EXTENSION% "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
	) else (
		call :exec %DBG_CALL2% hex2bin -e %MSX_FILE_EXTENSION% -l %BIN_SIZE% "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
	)
	call :debug %DBG_STEPS% Done building MSX binary.

	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Moving MSX binary...
	call :exec %DBG_EXTROVERT% copy %MSX_OBJ_PATH%\*.%MSX_FILE_EXTENSION% %MSX_BIN_PATH%\
	call :debug %DBG_STEPS% Done moving MSX binary.

	call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% Building symbol file...
	call :exec %DBG_EXTROVERT% python Make\symbol.py %MSX_OBJ_PATH%\ %MSX_FILE_NAME%
	call :debug %DBG_STEPS% Done building symbol file.

	exit /B

:finish
    call :debug %DBG_STEPS% -------------------------------------------------------------------------------
	call :debug %DBG_STEPS% All set. Happy MSX'ing.
    exit /B

#
# Orchestration
#

:orchestration
call :configure_target
call :opening
call :filesystem_settings
call :create_dir_struct
call :house_cleaning
call :application_settings

if /I not "%2"=="clean" GOTO :orchestration_cont1
call :clean
if /I not "%3"=="all" GOTO :orchestration_end

:orchestration_cont1
call :collect_include_dirs

if "%2"=="" GOTO :orchestration_compile
if /I "%2"=="all" GOTO :orchestration_all
if /I not "%3"=="all" GOTO :orchestration_end

:orchestration_all
call :build_lib

:orchestration_compile
call :compile
call :build_msx_bin

:orchestration_end
call :finish
exit 0
