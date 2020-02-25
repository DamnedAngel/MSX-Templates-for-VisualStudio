
echo -----------------------------------------------------------------------------------
echo MSX SDCC MAKEFILE by Danilo Angelo, 2020
echo version 0.3.3 - Codename ISA

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
echo // ALL CHANGES YOUR BE LOST.							>> TargetConfig.h
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
echo ; ALL CHANGES YOUR BE LOST.							>> TargetConfig.s
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
			set VALUE=!VALUE:[MSX_FILE_NAME]=%MSX_FILE_NAME%!
			set VALUE=!VALUE:[PROFILE]=%PROFILE%!
			set VALUE=!VALUE:[MSX_DEV_PATH]=%MSX_DEV_PATH%!
			set VALUE=!VALUE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
			set VALUE=!VALUE:[MSX_BIN_PATH]=%MSX_BIN_PATH%!
			set VALUE=!VALUE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
			set %%A=!VALUE!
		)
	)
)

echo.														>> TargetConfig.h
echo #endif	//  __TARGETCONFIG_H__							>> TargetConfig.h
echo Done target configuration files.

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

goto MEMORYMAPPING

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

:MEMORYMAPPING
IF EXIST MemoryMap.txt (
	echo -----------------------------------------------------------------------------------
	echo Building memory mapping file...
	echo ;-------------------------------------------------	>  memorymap.s
	echo ; memorymap.s created automatically by makefile	>> memorymap.s
	echo ; on %MSX_BUILD_TIME%, %MSX_BUILD_DATE%			>> memorymap.s
	echo ;													>> memorymap.s
	echo ; DO NOT BOTHER EDITING THIS.						>> memorymap.s
	echo ; ALL CHANGES YOUR BE LOST.						>> memorymap.s
	echo ;-------------------------------------------------	>> memorymap.s
	echo.													>> memorymap.s

	set USR_CALLS_FLAG=0
	echo.													> usrcalls.tmp
	for /F "tokens=1,2" %%A in  (MemoryMap.txt) do  (
		set TAG=%%A
		echo !TAG!
		if NOT "!TAG:~0,1!"==";" (
			if /I ".!TAG!"==".FILESTART" (
				echo fileStart .equ %%B						>> memorymap.s
				set CODE_LOC=%%B
			) else if /I ".!TAG!"==".CODE_LOC" (
				set CODE_LOC=%%B
			) else if /I ".!TAG!"==".DATA_LOC" (
				set DATA_LOC=%%B
			) else if /I ".!TAG!"==".PARAM_HANDLING_ROUTINE" (
				echo paramHandlingRoutine .equ %%B			>> memorymap.s
				echo PARAM_HANDLING_ROUTINE = %%B			>> memorymap.s
			) else if /I ".!TAG!"==".SYMBOL" (
				echo .globl %%B								>> usrcalls.tmp
				echo .dw %%B								>> usrcalls.tmp
				set USR_CALLS_FLAG=1
			) else if /I ".!TAG!"==".ADDRESS" (
				echo .dw %%B								>> usrcalls.tmp
				set USR_CALLS_FLAG=1
			)
		)
	)

	echo.													>> usrcalls.tmp

	if /I "!USR_CALLS_FLAG!"=="1" (
		echo.												>> memorymap.s
		echo .area _CODE									>> memorymap.s
		echo.												>> memorymap.s
		echo .macro USRCALLSINDEX							>> memorymap.s
		type usrcalls.tmp									>> memorymap.s
		echo .endm											>> memorymap.s
	)
	del usrcalls.tmp

	echo Done building memory mapping file.
)

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
echo Collecting Include Directories...
for /F "tokens=*" %%A in (IncludeDirectories.txt) do (
	set INCDIR=%%A
	if NOT "%INCDIR:~0,1%"==";" (
		set INCDIR=!INCDIR:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set INCDIR=!INCDIR:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set INCDIRS=!INCDIRS! -I!INCDIR!
	)
)

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
			sdcc -mz80 -c %INCDIRS% -o !RELFILE! !LIBFILE!
		) else (
			<NUL set /p=Processing ASM file !LIBFILE!... 
			sdasz80 -o !RELFILE! !LIBFILE!
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

for /F "tokens=*" %%A in (LibrarySources.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set RELFILE=%MSX_OBJ_PATH%\%%~nA.rel
		set OBJLIST=!OBJLIST! !RELFILE!
	)
)

for /F "tokens=*" %%A in (Libraries.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[MSX_OBJ_PATH]=%MSX_OBJ_PATH%!
		set OBJLIST=!OBJLIST! !LIBFILE!
	)
)

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
			echo sdcc -mz80 -c %INCDIRS% -o !RELFILE! !APPFILE!
			sdcc -mz80 -c %INCDIRS% -o !RELFILE! !APPFILE!
		) else (
			<NUL set /p=Processing ASM file !APPFILE!... 
			echo sdasz80 -o !RELFILE! !APPFILE!
			sdasz80 -o !RELFILE! !APPFILE!
		)
		if !errorlevel! NEQ 0 (
			echo FAIL!	
			echo Failed building %%A!
			EXIT !errorlevel!
		)
		echo Done.
		set OBJLIST=!OBJLIST! !RELFILE!
	)
)
echo Done building application modules.

IF "%CODE_LOC%"=="" (
	echo -----------------------------------------------------------------------------------
	echo Determining CODE-LOC...
	for /F "tokens=2,4" %%A in  (%MSX_OBJ_PATH%\msxdoscrt0.rel) do  (
		if "x%%A"=="x_HEADER0" (
			set /A DEC_CODE_LOC=0x0100+0x%%B
			call cmd /c exit /b !DEC_CODE_LOC!
			set CODE_LOC=0x!=exitcode!
		)
	)
	echo CODE-LOC determined to be !CODE_LOC!.
)

echo -----------------------------------------------------------------------------------
echo Compiling...
set SDCC_CALL=sdcc --code-loc %CODE_LOC% --data-loc %DATA_LOC% -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 %OBJLIST% %INCDIRS% -o %MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX
echo %SDCC_CALL%
%SDCC_CALL%
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done compiling.

echo -----------------------------------------------------------------------------------
echo Generating binary...
hex2bin -e %MSX_FILE_EXTENSION% %MSX_OBJ_PATH%\%MSX_FILE_NAME%.IHX
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done generating library.

echo -----------------------------------------------------------------------------------
echo Moving binary...
copy %MSX_OBJ_PATH%\*.%MSX_FILE_EXTENSION% %MSX_BIN_PATH%\
echo Done moving binary.
echo -----------------------------------------------------------------------------------
echo Building symbol file...
python Make\symbol.p %MSX_OBJ_PATH%\ %MSX_FILE_NAME%
if %errorlevel% NEQ 0 (
echo FAIL!
EXIT %errorlevel%
)
echo Done building symbol file.

:END
echo -----------------------------------------------------------------------------------
@echo on
EXIT
''