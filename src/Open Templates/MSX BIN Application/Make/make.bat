
echo -----------------------------------------------------------------------------------
echo MSX SDCC MAKEFILE by Danilo Angelo, 2020

set MSX_BUILD_TIME=%TIME% 
set MSX_BUILD_DATE=%DATE% 

set MSX_DEV_PATH=..\..\..
set MSX_LIB_PATH=%MSX_DEV_PATH%\libs
set PRJ_OBJ_PATH=%1\objs
set OBJLIST=
set INCDIRS=

SETLOCAL ENABLEDELAYEDEXPANSION

IF NOT EXIST %1 mkdir %1
IF NOT EXIST %1\objs mkdir %1\objs
IF NOT EXIST %1\bin mkdir %1\bin

if /I not "%3"=="clean" GOTO TARGETCONFIGURATION
echo -----------------------------------------------------------------------------------
echo Cleaning...
IF EXIST *.rel del *.rel /F /Q
IF EXIST %1\objs\*.* del %1\objs\*.* /F /Q
IF EXIST %1\bin\%2.com del %1\bin\%2.com
echo Done.

if /I not "%4"=="all" GOTO END

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

for /F "tokens=1,2" %%A in  (TargetConfig_%1.txt) do  (
	set TAG=%%A
	if NOT "%TAG:~0,1%"==";" (
		if /I "%%B"=="_off" (
		echo //#define %%A 										>> targetconfig.h
		echo %%A = 0											>> targetconfig.s
		) else if /I "%%B"=="_on" (
		echo #define %%A 										>> targetconfig.h
		echo %%A = 1											>> targetconfig.s
		) else if /I "%%B"=="" (
		echo #define %%A 										>> targetconfig.h
		echo %%A = 1											>> targetconfig.s
		) else if /I "%%A"=="FILENAME" (
		set FILENAME=%%B
		) else (
		echo #define %%A %%B									>> targetconfig.h
		echo %%A = %%B											>> targetconfig.s
		)
	)
)

echo.														>> TargetConfig.h
echo #endif	//  __TARGETCONFIG_H__							>> TargetConfig.h
echo Done target configuration files.

:MEMORYMAPPING
echo -----------------------------------------------------------------------------------
echo Building memory mapping file...
echo ;-------------------------------------------------		>  memorymap.s
echo ; memorymap.s created automatically by makefile		>> memorymap.s
echo ; on %MSX_BUILD_TIME%, %MSX_BUILD_DATE%				>> memorymap.s
echo ;														>> memorymap.s
echo ; DO NOT BOTHER EDITING THIS.							>> memorymap.s
echo ; ALL CHANGES YOUR BE LOST.							>> memorymap.s
echo ;-------------------------------------------------		>> memorymap.s
echo.														>> memorymap.s

for /F "tokens=1,2" %%A in  (MemoryMap.txt) do  (
	set TAG=%%A
	if NOT "%TAG:~0,1%"==";" (
		if /I "%%A"=="FILESTART" (
		echo fileStart .equ %%B								>> memorymap.s
		set CODE_LOC=%%B
		)
	)
)

echo.														>> memorymap.s
echo .area _CODE											>> memorymap.s
echo.														>> memorymap.s
echo .macro MEMORYMAP										>> memorymap.s

for /F "tokens=1,2" %%A in  (MemoryMap.txt) do  (
	set TAG=%%A
	if NOT "%TAG:~0,1%"==";" (
		if /I "%%A"=="SYMBOL" (
		echo .globl %%B										>> memorymap.s
		echo .dw %%B										>> memorymap.s
		) else if /I "%%A"=="ADDRESS" (
		echo .dw %%B										>> memorymap.s
		)
	)
)

echo .endm													>> memorymap.s

echo Done building memory mapping file.

if "%3"=="" GOTO COMPILE
if /I "%3"=="all" GOTO ALL
if /I not "%4"=="all" GOTO END

:ALL
echo -----------------------------------------------------------------------------------
echo Building libraries...
for /F "tokens=*" %%A in (LibrarySources.txt) do (
	set LIBFILE=%%A
	if NOT "%LIBFILE:~0,1%"==";" (
		set LIBFILE=!LIBFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set LIBFILE=!LIBFILE:[PRJ_OBJ_PATH]=%PRJ_OBJ_PATH%!
		set RELFILE=%1\objs\%%~nA.rel
		if /I "%%~xA"==".c" (
			<NUL set /p=Processing C file !LIBFILE!... 
			sdcc -mz80 -c -o !RELFILE! !LIBFILE!
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
		set LIBFILE=!LIBFILE:[PRJ_OBJ_PATH]=%PRJ_OBJ_PATH%!
		set RELFILE=%1\objs\%%~nA.rel
		set OBJLIST=!OBJLIST! !RELFILE!
	)
)

for /F "tokens=*" %%A in (RELs.txt) do (
	set RELFILE=%%A
	if NOT "%RELFILE:~0,1%"==";" (
		set RELFILE=!RELFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set RELFILE=!RELFILE:[PRJ_OBJ_PATH]=%PRJ_OBJ_PATH%!
		set OBJLIST=!OBJLIST! !RELFILE!
	)
)

echo -----------------------------------------------------------------------------------
echo Building application modules...
for /F "tokens=1" %%A in  (ApplicationSources.txt) do  (
	set APPFILE=%%A
	if NOT "%APPFILE:~0,1%"==";" (
		set APPFILE=!APPFILE:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set APPFILE=!APPFILE:[PRJ_OBJ_PATH]=%PRJ_OBJ_PATH%!
		set RELFILE=%1\objs\%%~nA.rel
		if /I "%%~xA"==".c" (
			<NUL set /p=Processing C file !APPFILE!... 
			echo sdcc -mz80 -c -o !RELFILE! !APPFILE!
			sdcc -mz80 -c -o !RELFILE! !APPFILE!
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


echo -----------------------------------------------------------------------------------
echo Compiling...

for /F "tokens=*" %%A in (IncludeDirectories.txt) do (
	set INCDIR=%%A
	if NOT "%INCDIR:~0,1%"==";" (
		set INCDIR=!INCDIR:[MSX_LIB_PATH]=%MSX_LIB_PATH%!
		set INCDIR=!INCDIR:[PRJ_OBJ_PATH]=%PRJ_OBJ_PATH%!
		set INCDIRS=!INCDIRS! -I!INCDIR!
	)
)

set SDCC_CALL=sdcc --code-loc %CODE_LOC% --data-loc 0 -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 %OBJLIST% %INCDIRS% -o %1\objs\%FILENAME%.IHX
rem set SDCC_CALL=sdcc --code-loc 0xb020 --data-loc 0 -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 %OBJLIST% %INCDIRS% -o %1\objs\%FILENAME%.IHX
echo %SDCC_CALL%
%SDCC_CALL%
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done compiling.

echo -----------------------------------------------------------------------------------
echo Generating binary...
hex2bin -e bin %1\objs\%FILENAME%.IHX
if %errorlevel% NEQ 0 (
EXIT %errorlevel%
)
echo Done generating library.

echo -----------------------------------------------------------------------------------
echo Moving binary...
copy %1\objs\*.bin %1\bin\
echo Done moving binary.
echo -----------------------------------------------------------------------------------
echo Building symbol file...
python Make\symbol.p %1\objs\ %FILENAME%
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