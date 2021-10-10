#!/usr/bin/env bash

# -----------------------------------------------------------------------------------
OPEN1="MSX SDCC Make Script Copyright © 2020-2021 Danilo Angelo, 2021 Pedro Medeiros"
OPEN2="version 00.05.01 - Codename Baltazar"
# -----------------------------------------------------------------------------------

IFS=$' \t\r\n'
SHELL_SCRIPT_EXTENSION='sh'

# retrieve current environment directory
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
MSX_BUILD_DATETIME=$(date)

MSX_FILE_NAME=MSXAPP
PROFILE=$1
MSX_OBJ_PATH=$PROFILE/objs
MSX_BIN_PATH=$PROFILE/bin
MSX_DEV_PATH=../../..
MSX_LIB_PATH=$MSX_DEV_PATH/libs
MSX_CFG_PATH=Config

OBJLIST=
INCDIRS=

BIN_SIZE=
FILE_START=0x0100
CODE_LOC=
DATA_LOC=0
PARAM_HANDLING_ROUTINE=0

DBG_MUTE=0
DBG_ERROR=10
DBG_OPENING=40
DBG_STEPS=50
DBG_SETTING=70
DBG_OUTPUT=100
DBG_DETAIL=120
DBG_CALL1=150
DBG_CALL2=160
DBG_CALL3=170
DBG_TOOLSDETAIL=190
DBG_EXTROVERT=200
DBG_PARAMS=230
DBG_VERBOSE=255
BUILD_DEBUG=$DBG_CALL2

#
# Helper Functions
#

path_replace () {
    P1=${1//\\//} # replace windows directory sep
    P1=${P1/"$2"/$3}
    echo "$P1"
}

replace_variables () {
    res=$1
    if [[ -n $res ]]; then
        res=$(path_replace "$res" '[PROFILE]' "$PROFILE")
        res=$(path_replace "$res" '[MSX_FILE_NAME]' "$MSX_FILE_NAME")
        res=$(path_replace "$res" '[MSX_FILE_EXTENSION]' "$MSX_FILE_EXTENSION")
        res=$(path_replace "$res" '[MSX_DEV_PATH]' "$MSX_DEV_PATH")
        res=$(path_replace "$res" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
        res=$(path_replace "$res" '[MSX_BIN_PATH]' "$MSX_BIN_PATH")
        res=$(path_replace "$res" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
        res=$(path_replace "$res" '[SHELL_SCRIPT_EXTENSION]' "$SHELL_SCRIPT_EXTENSION")
    fi
    echo "$res"
}

debug () {
    dbg=$1 && shift
    [[ "$dbg" -le "$BUILD_DEBUG" ]] && echo $@
}

_exec () {
    dbg=$1 && shift
    debug $dbg "## $@"
    if [[ "$DBG_PARAMS" -le "$BUILD_DEBUG" ]]; then
        for ((I=1; I<=${#@}; ++I)); do
            echo "ARG[$I]=${!I}"
        done
    fi
    OUTPUT=$(eval BUILD_DEBUG=$BUILD_DEBUG "$@")
    err=$?
    if [[ $err -ne 0 ]]; then
        [[ "$DBG_ERROR" -le "$BUILD_DEBUG" ]] && echo "$OUTPUT"
        debug $DBG_ERROR "### Error $err executing"
        debug $DBG_ERROR "### $@"
        exit $err
    fi
    if [[ "$DBG_OUTPUT" -le "$BUILD_DEBUG" ]]; then
        [[ ! -z $OUTPUT ]] && echo "$OUTPUT"
    fi
    return 0
}

exec_action () {
    n1=$1
    n2=$2
    shift
    shift
    if [[ -n $1 ]]; then
		debug $DBG_STEPS -------------------------------------------------------------------------------
		debug $DBG_STEPS Executing $n1 $n2 action...
        _exec $DBG_CALL3 $@
		debug $DBG_STEPS Done executing $n1 $n2 action.
	fi
}

#
# Build phases
#

configure_target() {
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

    if [[ ! -f "$MSX_CFG_PATH/TargetConfig_$PROFILE.txt" ]]; then
        debug $DBG_STEPS File TargetConfig_$PROFILE.txt not found.
        exit 1
    fi

    while read -r HEAD REST; do
        REST=${REST/;*/} # remove comment
        REST="${REST%"${REST##*[![:space:]]}"}" # remove trailing spaces
        if [[ -n $HEAD && ${HEAD:0:1} != ';' ]]; then
            if [[ ${HEAD:0:1} == '.' ]]; then
                TARGET_SECTION=$HEAD
            elif [[ $TARGET_SECTION == '.APPLICATION' ]]; then
                if [[ $REST == '_off' ]]; then
                    echo "//#define $HEAD"                  >> targetconfig.h
                    echo $HEAD = 0                          >> targetconfig.s
                elif [[ $REST == '_on' || -z $REST ]]; then
                    echo "#define $HEAD"                    >> targetconfig.h
                    echo $HEAD = 1                          >> targetconfig.s
                else
                    echo "#define $HEAD $REST"              >> targetconfig.h
                    echo $HEAD = $REST                      >> targetconfig.s
                fi
            else # .BUILD & .FILESYSTEM
                REST=$(replace_variables "$REST")
                eval $HEAD=\$REST   # indirect variable assignment
            fi
        fi
    done < "$MSX_CFG_PATH/TargetConfig_$PROFILE.txt"

    echo                                                        >> targetconfig.h
    echo '#endif //  __TARGETCONFIG_H__'                        >> targetconfig.h
}

configure_verbose_parameters() {
    if [[ "$DBG_TOOLSDETAIL" -le "$BUILD_DEBUG" ]]; then
        SDCC_DETAIL="-V --verbose" 
        SYMBOL_DETAIL="-v"
        HEX2BIN_DETAIL="-v"
    else
        SDCC_DETAIL=""
        SYMBOL_DETAIL=""
        HEX2BIN_DETAIL=""
    fi
}

configure_build_events() {
    shopt -s nocasematch # caseless matching

    if [[ ! -f "$MSX_CFG_PATH/BuildEvents.txt" ]]; then
        debug $DBG_STEPS File BuildEvents.txt not found.
        exit 1
    fi

    while read -r HEAD REST; do
        REST=${REST/;*/} # remove comment
        REST="${REST%"${REST##*[![:space:]]}"}" # remove trailing spaces
        if [[ -n $HEAD && ${HEAD:0:1} != ';' ]]; then
            REST=$(replace_variables "$REST")
            eval $HEAD=\$REST   # indirect variable assignment
        fi
    done < "$MSX_CFG_PATH/BuildEvents.txt"
}

opening() {
    debug $DBG_OPENING -------------------------------------------------------------------------------
    debug $DBG_OPENING $OPEN1
    debug $DBG_OPENING $OPEN2
    debug $DBG_SETTING "Build Debug Level $BUILD_DEBUG"
}

filesystem_settings() {
    debug $DBG_SETTING -------------------------------------------------------------------------------
    debug $DBG_SETTING Filesystem config...
    debug $DBG_SETTING Current dir: $CURRENT_DIR
    debug $DBG_SETTING Target file: ./$MSX_FILE_NAME.$MSX_FILE_EXTENSION
    debug $DBG_SETTING Object path: ./$MSX_OBJ_PATH
    debug $DBG_SETTING Binary path: ./$MSX_BIN_PATH
    debug $DBG_SETTING MSX dev path: ./$MSX_DEV_PATH
    debug $DBG_SETTING MSX lib path: ./$MSX_LIB_PATH
}

build_events_settings () {
    debug $DBG_EXTROVERT -------------------------------------------------------------------------------
    debug $DBG_EXTROVERT Build events config...
    if [[ -z $BUILD_START_ACTION ]]; then
        debug $DBG_EXTROVERT Build start action: [NONE]
    else
        debug $DBG_EXTROVERT Build start action: $BUILD_START_ACTION
    fi
    if [[ -z $BEFORE_COMPILE_ACTION ]]; then
        debug $DBG_EXTROVERT Before compile action: [NONE]
    else
        debug $DBG_EXTROVERT Before compile action: $BEFORE_COMPILE_ACTION
    fi
    if [[ -z $AFTER_COMPILE_ACTION ]]; then
        debug $DBG_EXTROVERT After compile action: [NONE]
    else
        debug $DBG_EXTROVERT After compile action: $AFTER_COMPILE_ACTION
    fi
    if [[ -z $AFTER_BINARY_ACTION ]]; then
        debug $DBG_EXTROVERT After binary generation action: [NONE]
    else
        debug $DBG_EXTROVERT After binary generation action: $AFTER_BINARY_ACTION
    fi
    if [[ -z $BUILD_END_ACTION ]]; then
        debug $DBG_EXTROVERT Build end action: [NONE]
    else
        debug $DBG_EXTROVERT Build end action: $BUILD_END_ACTION
    fi
}

create_dir_struct() {
    if [[ ! -d $MSX_OBJ_PATH ]]; then
        debug $DBG_STEPS -------------------------------------------------------------------------------
        debug $DBG_STEPS Creating OBJ path...
        _exec $DBG_EXTROVERT mkdir -p "$MSX_OBJ_PATH"
        debug $DBG_STEPS Done creating OBJ path.
    fi
    if [[ ! -d $MSX_BIN_PATH ]]; then
        debug $DBG_STEPS -------------------------------------------------------------------------------
        debug $DBG_STEPS Creating BIN path...
        _exec $DBG_EXTROVERT mkdir -p "$MSX_BIN_PATH"
        debug $DBG_STEPS Done creating BIN path.
    fi
}

house_cleaning() {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Making a small housecleaning.
    [[ -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]] && _exec $DBG_EXTROVERT rm "$MSX_OBJ_PATH"/bin_usrcalls.tmp
    [[ -f $MSX_OBJ_PATH/rom_callexpansionindex.tmp ]] && _exec $DBG_EXTROVERT rm "$MSX_OBJ_PATH"/rom_callexpansionindex.tmp
    [[ -f $MSX_OBJ_PATH/rom_callexpansionhandler.tmp ]] && _exec $DBG_EXTROVERT rm "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
    [[ -f $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp ]] && _exec $DBG_EXTROVERT rm "$MSX_OBJ_PATH"/rom_deviceexpansionindex.tmp
    [[ -f $MSX_OBJ_PATH/rom_deviceexpansionhandler.tmp ]] && _exec $DBG_EXTROVERT rm "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
    debug $DBG_STEPS Done housecleaning.
}

application_settings() {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Building application settings file...
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
                echo PARAM_HANDLING_ROUTINE = $REST             >> applicationsettings.s
            elif [[ $HEAD == 'SYMBOL' ]]; then
                if [[ ! -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]]; then
                    echo                                        >> "$MSX_OBJ_PATH"/bin_usrcalls.tmp
                fi
                echo .globl $REST                               >> "$MSX_OBJ_PATH"/bin_usrcalls.tmp
                echo .dw $REST                                  >> "$MSX_OBJ_PATH"/bin_usrcalls.tmp
            elif [[ $HEAD == 'ADDRESS' ]]; then
                if [[ ! -f $MSX_OBJ_PATH/bin_usrcalls.tmp ]]; then
                    echo                                        >> "$MSX_OBJ_PATH"/bin_usrcalls.tmp
                fi
                echo .dw $REST                                  >> "$MSX_OBJ_PATH"/bin_usrcalls.tmp
            elif [[ $HEAD == 'CALL_STATEMENT' ]]; then
                if [[ ! -f $MSX_OBJ_PATH/rom_callexpansionindex.tmp ]]; then
                    echo callStatementIndex::                   >> "$MSX_OBJ_PATH"/rom_callexpansionindex.tmp
                fi
                echo .dw        callStatement_$REST             >> "$MSX_OBJ_PATH"/rom_callexpansionindex.tmp
                echo .globl     _onCall$REST                    >> "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
                echo callStatement_$REST::                      >> "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
                echo ".ascii    '$REST\\0'"                     >> "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
                echo .dw        _onCall$REST                    >> "$MSX_OBJ_PATH"/rom_callexpansionhandler.tmp
            elif [[ $HEAD == 'DEVICE' ]]; then
                if [[ ! -f $MSX_OBJ_PATH/rom_deviceexpansionindex.tmp ]]; then
                    echo deviceIndex::                          >> "$MSX_OBJ_PATH"/rom_deviceexpansionindex.tmp
                fi
                echo .dw        device_$REST                    >> "$MSX_OBJ_PATH"/rom_deviceexpansionindex.tmp
                echo .globl     _onDevice${REST}_IO             >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
                echo .globl     _onDevice${REST}_getId          >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
                echo device_$REST::                             >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
                echo ".ascii     '$REST\\0'"                    >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
                echo .dw        _onDevice${REST}_IO             >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
                echo .dw        _onDevice${REST}_getId          >> "$MSX_OBJ_PATH"/rom_deviceexpansionhandler.tmp
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
    done < "$MSX_CFG_PATH/ApplicationSettings.txt"

    if [[ $PROJECT_TYPE == 'BIN' ]]; then
        debug $DBG_STEPS Adding specific BIN settings...
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
        debug $DBG_STEPS Adding specific ROM settings...
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

    debug $DBG_STEPS Done building application settings file.
}

clean() {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Cleaning...
    _exec $DBG_EXTROVERT rm -fv "$MSX_OBJ_PATH"/*
    _exec $DBG_EXTROVERT rm -fv "$MSX_BIN_PATH/$MSX_FILE_NAME.$MSX_FILE_EXTENSION"
    debug $DBG_STEPS Done cleaning.
}

collect_include_dirs() {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Collecting include directories...

    let I=0
    while read -r INCDIR; do
        if [[ -n $INCDIR && ${INCDIR:0:1} != ';' ]]; then
            INCDIR=$(path_replace "$INCDIR" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            INCDIR=$(path_replace "$INCDIR" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            INCDIRS[$I]="-I'$INCDIR'"
            I+=1
            debug $DBG_DETAIL "Collected $INCDIR"
        fi
    done < "$MSX_CFG_PATH/IncludeDirectories.txt"
    debug $DBG_STEPS Done collecting include directories.
}

build_lib() {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Building libraries...
    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            FILEEXT=$(basename "${LIBFILE/*./}")
            RELFILE="$MSX_OBJ_PATH"/$(basename "$LIBFILE" ".$FILEEXT").rel
            if [[ ".$FILEEXT" == '.c' ]]; then
                debug $DBG_DETAIL "Processing C file $(basename "$LIBFILE")... "
                _exec $DBG_CALL2 sdcc $SDCC_DETAIL $COMPILER_EXTRA_DIRECTIVES -mz80  -c ${INCDIRS[*]} -o "'$RELFILE'" "'$LIBFILE'"
            else
                debug $DBG_DETAIL "Processing ASM file $(basename "$LIBFILE")... "
                _exec $DBG_CALL2 sdasz80 $ASSEMBLER_EXTRA_DIRECTIVES -o "'$RELFILE'" "'$LIBFILE'"
            fi
        fi
    done < "$MSX_CFG_PATH/LibrarySources.txt"
    debug $DBG_STEPS Done building libraries.
}

compile () {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Building application modules...
    
    let I=0
    while read -r APPFILE; do
        if [[ -n $APPFILE && ${APPFILE:0:1} != ';' ]]; then
            APPFILE=$(path_replace "$APPFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            APPFILE=$(path_replace "$APPFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            FILEEXT=$(basename "${APPFILE/*./}")
            RELFILE="$MSX_OBJ_PATH"/$(basename "$APPFILE" ".$FILEEXT").rel
            if [[ ".$FILEEXT" == '.c' ]]; then
                debug $DBG_DETAIL "Processing C file $(basename "$APPFILE")... "
                _exec $DBG_CALL2 sdcc $SDCC_DETAIL $COMPILER_EXTRA_DIRECTIVES -mz80 -c ${INCDIRS[*]} -o "'$RELFILE'" "'$APPFILE'"
            else
                debug $DBG_DETAIL "Processing ASM file $(basename "$APPFILE")... "
                _exec $DBG_CALL2 sdasz80 $ASSEMBLER_EXTRA_DIRECTIVES -o "'$RELFILE'" "'$APPFILE'"
            fi
            OBJLIST[$I]="'$RELFILE'"
            I+=1
        fi
    done < "$MSX_CFG_PATH/ApplicationSources.txt"
    debug $DBG_STEPS Done building application modules.
    
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Collecting libraries...

    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            RELFILE="$MSX_OBJ_PATH"/$(basename "${LIBFILE%.*}").rel
            OBJLIST[$I]="'$RELFILE'"
            I+=1
            debug $DBG_DETAIL Collected $(basename "$RELFILE")
        fi
    done < "$MSX_CFG_PATH/LibrarySources.txt"
    
    while read -r LIBFILE; do
        if [[ -n $LIBFILE && ${LIBFILE:0:1} != ';' ]]; then
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_LIB_PATH]' "$MSX_LIB_PATH")
            LIBFILE=$(path_replace "$LIBFILE" '[MSX_OBJ_PATH]' "$MSX_OBJ_PATH")
            OBJLIST[$I]="'$LIBFILE'"
            I+=1
            debug $DBG_DETAIL Collected $(basename "$LIBFILE")
        fi
    done < "$MSX_CFG_PATH/Libraries.txt"
    debug $DBG_STEPS Done collecting libraries.
    
    if [[ -z $CODE_LOC ]]; then
        debug $DBG_STEPS -------------------------------------------------------------------------------
        debug $DBG_STEPS Determining CODE-LOC...
        for FILE in "$MSX_OBJ_PATH"/msx*crt0.rel; do
            debug $DBG_OUTPUT Analysing \"$FILE\"...
            while read -r F1 F2 F3 F4 F5; do
                if [[ $F2 == '_HEADER0' ]]; then
                    HEADER_SIZE_DEC=$((0x${F4}))
                    CODE_LOC_DEC=$(($FILE_START + $HEADER_SIZE_DEC))
                fi
            done < "$FILE"
        done

		HEADER_SIZE=$(printf '0x%04x' "$HEADER_SIZE_DEC")
		CODE_LOC=$(printf '0x%04x' "$CODE_LOC_DEC")
        debug $DBG_OUTPUT FILE_START is $FILE_START.
        debug $DBG_OUTPUT _HEADER segment size is $HEADER_SIZE.
        debug $DBG_OUTPUT CODE-LOC determined to be $CODE_LOC.
    fi
    debug $DBG_STEPS Done determining CODE-LOC.
    
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Compiling...
    _exec $DBG_CALL1 sdcc $SDCC_DETAIL $LINKER_EXTRA_DIRECTIVES --code-loc $CODE_LOC --data-loc $DATA_LOC -mz80 --no-std-crt0 ${OBJLIST[*]} ${INCDIRS[*]} -o "'$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx'"
    debug $DBG_STEPS Done compiling.
}

build_msx_bin () {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Build MSX binary...
    if [[ -z $BIN_SIZE ]]; then
        _exec $DBG_CALL3 hex2bin $HEX2BIN_DETAIL $EXECGEN_EXTRA_DIRECTIVES -e $MSX_FILE_EXTENSION "'$MSX_OBJ_PATH/$MSX_FILE_NAME.ihx'"
    else
        _exec $DBG_CALL3 hex2bin $HEX2BIN_DETAIL $EXECGEN_EXTRA_DIRECTIVES -e $MSX_FILE_EXTENSION -l $BIN_SIZE "'$MSX_OBJ_PATH'/'$MSX_FILE_NAME.ihx'"
    fi
    debug $DBG_STEPS Done building MSX binary.
    
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Moving binary...
    _exec $DBG_EXTROVERT mv "$MSX_OBJ_PATH/$MSX_FILE_NAME.$MSX_FILE_EXTENSION" "$MSX_BIN_PATH/"
    debug $DBG_STEPS Done moving binary.

    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS Building symbol file...
    _exec $DBG_CALL3 python Make/symbol.py "$MSX_OBJ_PATH/" "$MSX_FILE_NAME" $SYMBOL_DETAIL
    debug $DBG_STEPS Done building symbol file.
}

finish () {
    debug $DBG_STEPS -------------------------------------------------------------------------------
    debug $DBG_STEPS All set. Happy MSX\'ing!    
    exit 0
}

#
# Orchestration
#

configure_target
configure_verbose_parameters
configure_build_events
opening
filesystem_settings
build_events_settings
exec_action build start $BUILD_START_ACTION
create_dir_struct
house_cleaning
application_settings

if [[ $2 == 'clean' ]]; then
    clean
    [[ $3 != 'all' ]] && finish
fi

collect_include_dirs
exec_action before compile $BEFORE_COMPILE_ACTION

if [[ -z $2 ]]; then    # no parameters specified
    compile
    exec_action after compile $AFTER_COMPILE_ACTION
    build_msx_bin
    exec_action after binary $AFTER_BINARY_ACTION
    exec_action build end $BUILD_END_ACTION
    finish
fi

if [[ $2 == 'all' || $3 == 'all' ]]; then
    build_lib
    exec_action after compile $AFTER_COMPILE_ACTION
    compile
    build_msx_bin
    exec_action after binary $AFTER_BINARY_ACTION
    exec_action build end $BUILD_END_ACTION
    finish
fi
