
echo -----------------------------------------------------------------------------------
echo  MSX SDCC MAKEFILE Copyright (C) 2020-2021 Danilo Angelo
echo version 00.05.00 - Codename Mac'n'Tux

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

:TARGETCONFIGURATION
echo -----------------------------------------------------------------------------------
echo Building target configuration files...
echo //-------------------------------------------------	>  TargetConfig.h
echo // targetconfig.h created automatically by makefile	>> TargetConfig.h
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
echo ; targetconfig.s created automatically by makefile		>> TargetConfig.s
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
			echo Entering section !TARGET_SECTION!
		) else if /I "!TARGET_SECTION!"==".COMPILE" (
			if /I "%%B"=="_off" (
			echo //#define %%A								>> targetconfig.h
			echo %%A = 0									>> targetconfig.s
			) else if /I "%%B"=="_on" (
			echo #define %%A								>> targetconfig.h
			echo %%A = 1									>> targetconfig.s
			) else if /I "%%B"=="" (
			echo #define %%A 								>> targetconfig.h
			echo %%A = 1									>> targetconfig.s
			) else (
			echo #define %%A %%B							>> targetconfig.h
			echo %%A = %%B									>> targetconfig.s
			)
		) else if /I "!TARGET_SECTION!"==".FILESYSTEM" (
			set VALUE=%%B

			rem replaces PROFILE
			set SEARCH_STR=[PROFILE]
			set REPLACE_STR=!PROFILE!
			call :STR_REPLACE
			
			rem replaces MSX_FILE_NAME 
			set SEARCH_STR=[MSX_FILE_NAME]
			set REPLACE_STR=!MSX_FILE_NAME!
			call :STR_REPLACE

			rem replaces MSX_FILE_EXTENSION
			set SEARCH_STR=[MSX_FILE_EXTENSION]
			set REPLACE_STR=!MSX_FILE_EXTENSION!
			call :STR_REPLACE

			rem replaces MSX_DEV_PATH
			set SEARCH_STR=[MSX_DEV_PATH]
			set REPLACE_STR=!MSX_DEV_PATH!
			call :STR_REPLACE

			rem replaces MSX_OBJ_PATH
			set SEARCH_STR=[MSX_OBJ_PATH]
			set REPLACE_STR=!MSX_OBJ_PATH!
			call :STR_REPLACE
			
			rem replaces MSX_BIN_PATH
			set SEARCH_STR=[MSX_BIN_PATH]
			set REPLACE_STR=!MSX_BIN_PATH!
			call :STR_REPLACE
			
			rem replaces MSX_LIB_PATH
			set SEARCH_STR=[MSX_LIB_PATH]
			set REPLACE_STR=!MSX_LIB_PATH!
			call :STR_REPLACE
			
			set %%A=!VALUE!
		)
	)
)

echo.														>> TargetConfig.h
echo #endif	//  __TARGETCONFIG_H__							>> TargetConfig.h
echo Done target configuration files.

goto FS_SETTINGS

:STR_REPLACE
set VALUE=!VALUE:%SEARCH_STR%=%REPLACE_STR%!
EXIT /B

:FS_SETTINGS
echo -----------------------------------------------------------------------------------
echo Filesystem settings:
echo MSX_FILE_NAME=%MSX_FILE_NAME%
echo MSX_OBJ_PATH=!MSX_OBJ_PATH!
echo MSX_BIN_PATH=!MSX_BIN_PATH!
echo MSX_DEV_PATH=!MSX_DEV_PATH!
echo MSX_LIB_PATH=!MSX_LIB_PATH!

if NOT EXIST "%MSX_OBJ_PATH%" (
	echo -----------------------------------------------------------------------------------
	echo Creating OBJ path...
	set NEW_PATH=%MSX_OBJ_PATH%
	CALL :CREATE_DIR
	echo Done creating OBJ path.
)
if NOT EXIST "%MSX_BIN_PATH%" (
	echo -----------------------------------------------------------------------------------
	echo Creating BIN path...
	set NEW_PATH=%MSX_BIN_PATH%
	CALL :CREATE_DIR
	echo Done creating BIN path.
)

goto APPLICATIONSETTINGS

:CREATE_DIR
set ACC_PATH=.
:CREATE_DIR_LOOP
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
if defined NEW_PATH goto :CREATE_DIR_LOOP
EXIT /B

:APPLICATIONSETTINGS
IF EXIST %MSX_OBJ_PATH%\bin_usrcalls.tmp del %MSX_OBJ_PATH%\bin_usrcalls.tmp
IF EXIST %MSX_OBJ_PATH%\rom_callexpansionindex.tmp del %MSX_OBJ_PATH%\rom_callexpansionindex.tmp
IF EXIST %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp del %MSX_OBJ_PATH%\rom_callexpansionhandler.tmp
IF EXIST %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp del %MSX_OBJ_PATH%\rom_deviceexpansionindex.tmp
IF EXIST %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp del %MSX_OBJ_PATH%\rom_deviceexpansionhandler.tmp

echo -----------------------------------------------------------------------------------
echo Building application settings file...
echo ;-------------------------------------------------		>  applicationsettings.s
echo ; applicationsettings.s created automatically			>> applicationsettings.s
echo ; by makefile											>> applicationsettings.s
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
REM			echo PROJECT_TYPE = %%B							>> applicationsettings.s
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

echo Done building application settings file.

if /I not "%2"=="clean" GOTO :BUILD
echo -----------------------------------------------------------------------------------
echo Cleaning...
IF EXIST *.rel del *.rel /F /Q
IF EXIST %MSX_OBJ_PATH%\*.* del %MSX_OBJ_PATH%\*.* /F /Q
IF EXIST %MSX_BIN_PATH%\%MSX_FILE_NAME%.%MSX_FILE_EXTENSION% del %MSX_BIN_PATH%\%MSX_FILE_NAME%.%MSX_FILE_EXTENSION%

echo Done cleaning.
if /I not "%3"=="all" GOTO END

:BUILD
echo -----------------------------------------------------------------------------------
echo Collecting include cirectories...
for /F "tokens=*" %%A in (IncludeDirectories.txt) do (
	set INCDIR=%%A
	if NOT "%INCDIR:~0,1%"==";" (
		set INCDIR=!INCDIR:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set INCDIR=!INCDIR:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set INCDIRS=!INCDIRS! -I"!INCDIR!"
		echo Collected !INCDIR!
	)
)

echo Done collecting include directories.

if "%2"=="" GOTO COMPILE
if /I "%2"=="all" GOTO ALL
if /I not "%3"=="all" GOTO END

:ALL
echo -----------------------------------------------------------------------------------
echo Building libraries...
for /F "tokens=*" %%A in (LibrarySources.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
		if /I "%%~xA"==".c" (
			<NUL set /p=Processing C file !LIBFILE!... 
			sdcc -mz80 -c %INCDIRS% -o "!RELFILE!" "!LIBFILE!"
		) else (
			<NUL set /p=Processing ASM file !LIBFILE!... 
			sdasz80 -o "!RELFILE!" "!LIBFILE!"
		)
		if !errorlevel! NEQ 0 (
			echo FAIL!
			echo Failed building %%A!
			EXIT !errorlevel!
		)
		echo Done.
	)
)
echo Done building libraries.

:COMPILE

echo -----------------------------------------------------------------------------------
echo Building application modules...
for /F "tokens=1" %%A in  (ApplicationSources.txt) do  (
	set APPFILE=%%A
	if NOT "%APPFILE:~0,1%"==";" (
		set APPFILE=!APPFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set APPFILE=!APPFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
		if /I "%%~xA"==".c" (
			<NUL set /p=Processing C file !APPFILE!... 
			echo sdcc -mz80 -c %INCDIRS% -o "!RELFILE!" "!APPFILE!"
			sdcc -mz80 -c %INCDIRS% -o "!RELFILE!" "!APPFILE!"
		) else (
			<NUL set /p=Processing ASM file !APPFILE!... 
			sdasz80 -o "!RELFILE!" "!APPFILE!"
		)
		if !errorlevel! NEQ 0 (
			echo FAIL!	
			echo Failed building %%A!
			EXIT !errorlevel!
		)
		echo Done.
		set OBJLIST=!OBJLIST! "!RELFILE!"
	)
)
echo Done building application modules.

echo -----------------------------------------------------------------------------------
echo Collecting libraries...

for /F "tokens=*" %%A in (LibrarySources.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
		set OBJLIST=!OBJLIST! "!RELFILE!"
		echo Collected !RELFILE!
	)
)

for /F "tokens=*" %%A in (Libraries.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set OBJLIST=!OBJLIST! !LIBFILE!
		echo Collected !LIBFILE!
	)
)

echo Done collecting libraries.

IF "%CODE_LOC%"=="" (
	echo -----------------------------------------------------------------------------------
	echo Determining CODE-LOC...
	for %%f IN (%MSX_OBJ_PATH%\msx*crt0.rel) DO (
		echo Analyzing %%f...
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
	echo FILE_START is %FILE_START%.
	echo _HEADER segment size is !HEADER_SIZE!.
	echo CODE-LOC determined to be !CODE_LOC!.
)

echo -----------------------------------------------------------------------------------
echo Compiling...
set SDCC_CALL=sdcc --code-loc %CODE_LOC% --data-loc %DATA_LOC% -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 %OBJLIST% %INCDIRS% -o "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
echo %SDCC_CALL%
%SDCC_CALL%
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done compiling.

echo -----------------------------------------------------------------------------------
echo Generating binary...
if ".%BIN_SIZE%"=="." (
	hex2bin -e %MSX_FILE_EXTENSION% "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
) else (
	hex2bin -e %MSX_FILE_EXTENSION% -l %BIN_SIZE% "%MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX"
)
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done generating library.

echo -----------------------------------------------------------------------------------
echo Moving binary...
copy %MSX_OBJ_PATH%\*.%MSX_FILE_EXTENSION% %MSX_BIN_PATH%\
if %errorlevel% NEQ 0 (
echo FAIL!
EXIT %errorlevel%
)
echo Done moving binary.
echo -----------------------------------------------------------------------------------
echo Building symbol file...
python Make\symbol.py %MSX_OBJ_PATH%\ %MSX_FILE_NAME%
if %errorlevel% NEQ 0 (
echo FAIL!
EXIT %errorlevel%
)
echo Done building symbol file.

:END
echo -----------------------------------------------------------------------------------
@echo on
EXIT
