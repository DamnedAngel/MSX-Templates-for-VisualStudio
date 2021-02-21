#!/bin/sh

echo -----------------------------------------------------------------------------------
echo MSX SDCC MAKEFILE Copyright © 2020-2021 Danilo Angelo, 2021 Pedro Medeiros
echo version 00.04.01 - Codename JUNIOR

# retrieve current environment directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
MSX_BUILD_DATETIME=$(date)

MSX_FILE_NAME=MSXAPP
PROFILE=$1
MSX_OBJ_PATH=$PROFILE/objs
MSX_BIN_PATH=$PROFILE/bin
MSX_DEV_PATH=../../..
MSX_LIB_PATH=$MSX_DEV_PATH/libs

OBJLIST=
INCDIRS=

BIN_SIZE=
FILE_START=0x0100
CODE_LOC=
DATA_LOC=0
PARAM_HANDLING_ROUTINE=0

#
# Functions
#

path_replace () {
    P1=${1//\\//} # replace windows directory sep
    P1=${P1/"$2"/$3}
    echo "$P1"
}

create_dir_struct() {
    if [[ ! -d $MSX_OBJ_PATH ]]; then
        echo -----------------------------------------------------------------------------------
        echo Creating OBJ path...
        mkdir -p "$MSX_OBJ_PATH"
        echo Done creating OBJ path.
    fi
    if [[ ! -d $MSX_BIN_PATH ]]; then
        echo -----------------------------------------------------------------------------------
        echo Creating BIN path...
        mkdir -p "$MSX_BIN_PATH"
        echo Done creating BIN path.
    fi
}

build_lib () {
    echo -----------------------------------------------------------------------------------
    echo Building libraries...
    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            RELFILE="$MSX_OBJ_PATH"/$(basename "${LIBFILE/.*/}").rel
            FILEEXT=$(basename "${LIBFILE/*./}")
            if [[ ".$FILEEXT" == '.c' ]]; then
                echo -n Processing C file $(basename "$LIBFILE")...
                TMPFILE=$(mktemp $(basename "$RELFILE.XXXXX"))
                sdcc -mz80 -c $INCDIRS -o "$RELFILE" "$LIBFILE" 2> "$TMPFILE"
            else
                echo -n Processing ASM file $(basename "$LIBFILE")...
                TMPFILE=$(mktemp $(basename "$RELFILE.XXXXX"))
                sdasz80 -o "$RELFILE" "$LIBFILE" 2> "$TMPFILE"
            fi
            if [[ $? -ne 0 ]]; then
                echo FAIL!
                echo Failed building $(basename "$LIBFILE"):
                cat "$TMPFILE"
                rm "$TMPFILE"
                exit $?
            fi
            rm "$TMPFILE"
            echo Done.
    fi
    done < LibrarySources.txt
    echo Done building libraries.
}

compile () {
    echo -----------------------------------------------------------------------------------
    echo Building application modules...
    
    OBJLIST=
    while read -r APPFILE; do
        if [[ -n $APPFILE && ${APPFILE:0:1} != ';' ]]; then
            APPFILE=$(path_replace "$APPFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            APPFILE=$(path_replace "$APPFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            RELFILE="$MSX_OBJ_PATH"/$(basename "${APPFILE/.*/}").rel
            FILEEXT=$(basename "${APPFILE/*./}")
            if [[ ".$FILEEXT" == '.c' ]]; then
                echo Processing C file $(basename "$APPFILE")...
                TMPFILE=$(mktemp $(basename "$RELFILE.XXXXX"))
                echo sdcc -mz80 -c $INCDIRS -o "$RELFILE" "$APPFILE"
                sdcc -mz80 -c $INCDIRS -o "$RELFILE" "$APPFILE" 2> "$TMPFILE"
            else
                echo Processing ASM file $(basename "$APPFILE")...
                TMPFILE=$(mktemp $(basename "$RELFILE.XXXXX"))
                echo sdasz80 -o "$RELFILE" "$APPFILE"
                sdasz80 -o "$RELFILE" "$APPFILE" 2> "$TMPFILE"
            fi
            if [[ $? -ne 0 ]]; then
                echo FAIL!
                echo Failed building $(basename "$APPFILE"):
                cat "$TMPFILE"
                rm "$TMPFILE"
                exit $?
            fi
            rm "$TMPFILE"
            echo Done.
            OBJLIST="$OBJLIST '$RELFILE'"
        fi
    done < ApplicationSources.txt
    echo Done building application modules.
    
    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            RELFILE="$MSX_OBJ_PATH"/$(basename "${LIBFILE/.*/}").rel
            OBJLIST="$OBJLIST '$RELFILE'"
        fi
    done < LibrarySources.txt
    
    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            OBJLIST="$OBJLIST '$LIBFILE'"
        fi
    done < Libraries.txt
    
    if [[ -z $CODE_LOC ]]; then
        echo -----------------------------------------------------------------------------------
        echo Determining CODE-LOC...
        for FILE in "$MSX_OBJ_PATH"/msx*crt0.rel; do
            echo Analysing $FILE...
            while read -r F1 F2 F3 F4 F5; do
                if [[ $F2 == '_HEADER0' ]]; then
                    HEADER_SIZE=$((0x${F4}))
                    CODE_LOC=$(($FILE_START + $HEADER_SIZE))
                fi
            done < $FILE
        done
        echo FILE_START is $FILE_START.
        echo _HEADER segment size is $HEADER_SIZE.
        echo CODE-LOC determined to be $CODE_LOC.
    fi
    
    echo -----------------------------------------------------------------------------------
    echo Compiling...
    eval sdcc --code-loc $CODE_LOC --data-loc $DATA_LOC -mz80 --no-std-crt0 --opt-code-size --disable-warning 196 $OBJLIST $INCDIRS -o "'$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx'"
    if [[ $? -ne 0 ]]; then
        exit $?
    fi
    echo Done compiling.
}

build_bin () {
    echo -----------------------------------------------------------------------------------
    if [[ -z $BIN_SIZE ]]; then
        echo Generating $MSX_FILE_EXTENSION binary...
        echo hex2bin -e $MSX_FILE_EXTENSION "$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx"
        hex2bin -e $MSX_FILE_EXTENSION "$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx"
    else
        echo Generating $MSX_FILE_EXTENSION binary of $((16#$BIN_SIZE)) bytes in length...
        echo hex2bin -e $MSX_FILE_EXTENSION -l $BIN_SIZE "$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx"
        hex2bin -e $MSX_FILE_EXTENSION -l $BIN_SIZE "$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx"
    fi
    if [[ $? -ne 0 ]]; then
        exit $?
    fi
    echo Done generating library.
    
    echo -----------------------------------------------------------------------------------
    echo Moving binary...
    mv "$MSX_OBJ_PATH/$MSX_FILE_NAME.$MSX_FILE_EXTENSION" "$MSX_BIN_PATH/"
    if [[ $? -ne 0 ]]; then
        echo FAIL!
        exit $?
    fi
    echo Done moving binary.
    echo -----------------------------------------------------------------------------------
    
    echo Building symbol file...
    python Make/symbol.py "$MSX_OBJ_PATH/" "$MSX_FILE_NAME"
    if [[ $? -ne 0 ]]; then
        echo FAIL!
        exit $?
    fi
    echo Done building symbol file.
}

finish () {
    echo -----------------------------------------------------------------------------------
    exit 0
}

#:TARGETCONFIGURATION
echo -----------------------------------------------------------------------------------
echo Building target configuration files...
echo //------------------------------------------------     >  targetconfig.h
echo // targetconfig.h created automatically by make.sh     >> targetconfig.h
echo // on $MSX_BUILD_DATETIME                              >> targetconfig.h
echo //                                                     >> targetconfig.h
echo // DO NOT BOTHER EDITING THIS.                         >> targetconfig.h
echo // ALL CHANGES WILL BE LOST.                           >> targetconfig.h
echo //------------------------------------------------     >> targetconfig.h
echo                                                        >> targetconfig.h
echo '#ifndef  __TARGETCONFIG_H__'                          >> targetconfig.h
echo '#define  __TARGETCONFIG_H__'                          >> targetconfig.h
echo                                                        >> targetconfig.h

echo ';-------------------------------------------------'   >  targetconfig.s
echo '; targetconfig.s created automatically by make.sh'    >> targetconfig.s
echo "; on $MSX_BUILD_DATETIME"                             >> targetconfig.s
echo ';'                                                    >> targetconfig.s
echo '; DO NOT BOTHER EDITING THIS.'                        >> targetconfig.s
echo '; ALL CHANGES WILL BE LOST.'                          >> targetconfig.s
echo ';-------------------------------------------------'   >> targetconfig.s
echo                                                        >> targetconfig.s

shopt -s nocasematch # caseless matching

if [[ ! -f "TargetConfig_$PROFILE.txt" ]]; then
    echo File TargetConfig_$PROFILE.txt not found.
    exit 1
fi

while read -r HEAD REST; do
    REST=${REST/;*/} # remove comment
    REST="${REST%"${REST##*[![:space:]]}"}" # remove trailing spaces
    if [[ -n $HEAD && ${HEAD:0:1} != ';' ]]; then
        if [[ ${HEAD:0:1} == '.' ]]; then
            TARGET_SECTION=$HEAD
            echo Entering section $TARGET_SECTION
        elif [[ $TARGET_SECTION == '.COMPILE' ]]; then
            if [[ $REST == '_off' ]]; then
                echo "//#define $HEAD"                      >> targetconfig.h
                echo $HEAD = 0                              >> targetconfig.s
            elif [[ $REST == '_on' || -z $REST ]]; then
                echo "#define $HEAD"                        >> targetconfig.h
                echo $HEAD = 1                              >> targetconfig.s
            else
                echo "#define $HEAD $REST"                  >> targetconfig.h
                echo $HEAD = $REST                          >> targetconfig.s
            fi
        elif [[ $TARGET_SECTION == '.FILESYSTEM' ]]; then
            # replaces PROFILE
            if [[ -n $REST ]]; then
                REST=$(path_replace "$REST" '[PROFILE]' "$PROFILE")
                REST=$(path_replace "$REST" '[MSX_FILE_NAME]' "$MSX_FILE_NAME")
                REST=$(path_replace "$REST" '[MSX_FILE_EXTENSION]' "$MSX_FILE_EXTENSION")
                REST=$(path_replace "$REST" '[MSX_DEV_PATH]' "$MSX_DEV_PATH")
                REST=$(path_replace "$REST" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
                REST=$(path_replace "$REST" '[MSX_BIN_PATH]' "$MSX_BIN_PATH")
                REST=$(path_replace "$REST" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
                typeset "$HEAD=$REST" # indirect variable assignment
                if [[ -z $REST ]]; then
                    echo Warning: variable $HEAD erased.
                fi
            fi
        fi
    fi
done < "TargetConfig_$PROFILE.txt"

echo                                                        >> targetconfig.h
echo '#endif //  __TARGETCONFIG_H__'                        >> targetconfig.h
echo Done target configuration files.

#:FS_SETTINGS
echo -----------------------------------------------------------------------------------
echo Filesystem settings:
echo MSX_FILE_NAME=$DIR/$MSX_FILE_NAME
echo MSX_OBJ_PATH=$DIR/$MSX_OBJ_PATH
echo MSX_BIN_PATH=$DIR/$MSX_BIN_PATH
echo MSX_DEV_PATH=$DIR/$MSX_DEV_PATH
echo MSX_LIB_PATH=$DIR/$MSX_LIB_PATH

create_dir_struct

#:APPLICATIONSETTINGS
[[ -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]] && rm "$MSX_OBJ_PATH"/bin_usrcalls.tmp
[[ -f $MSX_OBJ_PATH/rom_callexpansionindex.tmp ]] && rm "$MSX_OBJ_PATH"/rom_callexpansionindex.tmp
[[ -f $MSX_OBJ_PATH/rom_callexpansionhandler.tmp ]] && rm "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
[[ -f $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp ]] && rm "$MSX_OBJ_PATH"/rom_deviceexpansionindex.tmp
[[ -f $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp ]] && rm "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp

echo -----------------------------------------------------------------------------------
echo Building application settings file...
echo ';-------------------------------------------------'   >  applicationsettings.s
echo '; applicationsettings.s created automatically'        >> applicationsettings.s
echo '; by make.sh'                                         >> applicationsettings.s
echo "; on $MSX_BUILD_DATETIME"                             >> applicationsettings.s
echo ';'                                                    >> applicationsettings.s
echo '; DO NOT BOTHER EDITING THIS.'                        >> applicationsettings.s
echo '; ALL CHANGES WILL BE LOST.'                          >> applicationsettings.s
echo ';-------------------------------------------------'   >> applicationsettings.s
echo                                                        >> applicationsettings.s

while read -r HEAD REST
do
    REST=${REST/;*/} # remove comment
    REST="${REST%"${REST##*[![:space:]]}"}" # remove trailing spaces
    if [[ -n $HEAD && ${HEAD:0:1} != ';' ]]; then
        if [[ $HEAD == 'PROJECT_TYPE' ]]; then
            # echo PROJECT_TYPE = $REST
            PROJECT_TYPE=$REST
        elif [[ $HEAD == 'FILESTART' ]]; then
            echo fileStart .equ $REST                       >> applicationsettings.s
            FILE_START=$REST
        elif [[ $HEAD == 'ROM_SIZE' ]]; then
            if [[ $REST == '16k' ]]; then
                BIN_SIZE=4000
            else
                BIN_SIZE=8000
            fi
        elif [[ $HEAD == 'CODE_LOC' ]]; then
            CODE_LOC=$REST
        elif [[ $HEAD == 'DATA_LOC' ]]; then
            DATA_LOC=$REST
        elif [[ $HEAD == 'PARAM_HANDLING_ROUTINE' ]]; then
            echo paramHandlingRoutine .equ $REST            >> applicationsettings.s
            echo PARAM_HANDLING_ROUTINE = $REST
        elif [[ $HEAD == 'SYMBOL' ]]; then
            if [[ ! -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]]; then
                echo                                        >> $MSX_OBJ_PATH/bin_usrcalls.tmp
            fi
            echo .globl $REST                               >> $MSX_OBJ_PATH/bin_usrcalls.tmp
            echo .dw $REST                                  >> $MSX_OBJ_PATH/bin_usrcalls.tmp
        elif [[ $HEAD == 'ADDRESS' ]]; then
            if [[ ! -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]]; then
                echo                                        >> $MSX_OBJ_PATH/bin_usrcalls.tmp
            fi
            echo .dw $REST                                  >> $MSX_OBJ_PATH/bin_usrcalls.tmp
        elif [[ $HEAD == 'CALL_STATEMENT' ]]; then
            if [[ ! -f $MSX_OBJ_PATH/rom_callexpansionindex.tmp ]]; then
                echo callStatementIndex::                   >> $MSX_OBJ_PATH/rom_callexpansionindex.tmp
            fi
            echo .dw        callStatement_$REST             >> $MSX_OBJ_PATH/rom_callexpansionindex.tmp
            echo .globl     _onCall$REST                    >> $MSX_OBJ_PATH/rom_callexpansionhandler.tmp
            echo callStatement_$REST::                      >> $MSX_OBJ_PATH/rom_callexpansionhandler.tmp
            echo ".ascii    '$REST\\0'"                     >> $MSX_OBJ_PATH/rom_callexpansionhandler.tmp
            echo .dw        _onCall$REST                    >> $MSX_OBJ_PATH/rom_callexpansionhandler.tmp
        elif [[ $HEAD == 'DEVICE' ]]; then
            if [[ ! -f $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp ]]; then
                echo deviceIndex::                          >> $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp
            fi
            echo .dw        device_$REST                    >> $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp
            echo .globl     _onDevice${REST}_IO             >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
            echo .globl     _onDevice${REST}_getId          >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
            echo device_$REST::                             >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
            echo ".ascii     '$REST\\0'"                    >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
            echo .dw        _onDevice${REST}_IO             >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
            echo .dw        _onDevice${REST}_getId          >> $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp
        else
            if [[ $REST == '_off' ]]; then
                echo $HEAD = 0                              >> applicationsettings.s
            elif [[ $REST == '_on' || -z $REST ]]; then
                echo $HEAD = 1                              >> applicationsettings.s
            else
                echo $HEAD = $REST                          >> applicationsettings.s
            fi
        fi
    fi
done < ApplicationSettings.txt

if [[ $PROJECT_TYPE == 'BIN' ]]; then
    echo Adding specific BIN settings...
    echo .macro MCR_USRCALLSINDEX                           >> applicationsettings.s
    if [[ -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]]; then
        echo                                                >> applicationsettings.s
        echo _BASIC_USR_INDEX::                             >> applicationsettings.s
        cat "$MSX_OBJ_PATH/bin_usrcalls.tmp"                >> applicationsettings.s
        rm "$MSX_OBJ_PATH/bin_usrcalls.tmp"
    fi
    echo .endm                                              >> applicationsettings.s
fi

if [[ $PROJECT_TYPE == 'ROM' ]]; then
    echo Adding specific ROM settings...
    echo                                                    >> applicationsettings.s
    echo .macro MCR_CALLEXPANSIONINDEX                      >> applicationsettings.s
    if [[ -f $MSX_OBJ_PATH/rom_callexpansionindex.tmp ]]; then
        cat "$MSX_OBJ_PATH/rom_callexpansionindex.tmp"      >> applicationsettings.s
        echo '.dw       #0'                                 >> applicationsettings.s
        cat "$MSX_OBJ_PATH/rom_callexpansionhandler.tmp"    >> applicationsettings.s
        rm "$MSX_OBJ_PATH/rom_callexpansionindex.tmp"
        rm "$MSX_OBJ_PATH/rom_callexpansionhandler.tmp"
    fi
    echo .endm                                              >> applicationsettings.s

    echo                                                    >> applicationsettings.s
    echo .macro MCR_DEVICEEXPANSIONINDEX                    >> applicationsettings.s
    if [[ -f $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp ]]; then
        cat "$MSX_OBJ_PATH/rom_deviceexpansionindex.tmp"    >> applicationsettings.s
        echo '.dw       #0'                                 >> applicationsettings.s
        cat "$MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp"  >> applicationsettings.s
        rm "$MSX_OBJ_PATH/rom_deviceexpansionindex.tmp"
        rm "$MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp"
    fi
    echo .endm                                              >> applicationsettings.s
fi

echo Done building application settings file.

if [[ $2 == 'clean' ]]; then
    echo -----------------------------------------------------------------------------------
    echo Cleaning...
    [[ -d $PROFILE ]] && rm -rv "$PROFILE"
    echo Done cleaning.
    [[ $3 != 'all' ]] && finish
    create_dir_struct
fi

#:BUILD
echo -----------------------------------------------------------------------------------
echo Collecting Include Directories...

INCDIRS=
while read -r INCDIR; do
    if [[ -n $INCDIR && ${INCDIR:0:1} != ';' ]]; then
        INCDIR=$(path_replace "$INCDIR" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
        INCDIR=$(path_replace "$INCDIR" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
        INCDIRS="$INCDIRS -I'$INCDIR'"
    fi
done < IncludeDirectories.txt
echo "INCDIRS=$INCDIRS"

# no parameters specified
if [[ -z $2 ]]; then
    compile
    build_bin
    finish
fi

if [[ $2 == 'all' || $3 == 'all' ]]; then
    build_lib
    compile
    build_bin
    finish
fi

