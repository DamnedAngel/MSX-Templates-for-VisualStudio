# ----------------------------------------------------------
#		make.py - by Danilo Angelo, 2023
#
#		Build script for MSX projects.
# ----------------------------------------------------------

import string
import sys
import os
import platform
from datetime import datetime, date

# -----------------------------------------------------------------------------------
OPEN1 = 'MSX SDCC Make Script Copyright © 2020-2023 Danilo Angelo, 2021 Pedro Medeiros'
OPEN2 = 'version 00.06.00 alpha 1 - Codename Sam'
# -----------------------------------------------------------------------------------

ARG1 = sys.argv[1]
ARG2 = sys.argv[2]
ARG3 = sys.argv[3]

CURRENT_DIR = os.getcwd()
MSX_BUILD_TIME = datetime.now().strftime('%H:%M:%S')
MSX_BUILD_DATE = date.today()
if platform.system()=='Windows':
    SHELL_SCRIPT_EXTENSION = 'BAT'
else:
    SHELL_SCRIPT_EXTENSION = 'sh'
    
MSX_FILE_NAME = 'MSXAPP'
PROFILE = ARG1
MSX_OBJ_PATH = '{}\objs'.format(PROFILE)
MSX_BIN_PATH = '{}\bin'.format(PROFILE)
MSX_DEV_PATH = '..\..\..'
MSX_LIB_PATH = '{}\libs'.format(MSX_DEV_PATH)
MSX_CFG_PATH = 'Config'

OBJLIST = []
INCDIRS = []

SDCC_CALL = 1
CODE_AFTER_MDO = 0
BIN_SIZE = None
FILE_START = 0x0100
DEC_HEADER_SIZE = 0
CODE_LOC = None
DATA_LOC = 0
PARAM_HANDLING_ROUTINE = 0

MDO_SUPPORT = 0
MDO_PARENT_OBJ_PATH = None
MDO_PARENT_AFTERHEAP = None

DBG_MUTE = 0
DBG_ERROR = 10
DBG_OPENING = 40
DBG_STEPS = 50
DBG_SETTING = 70
DBG_OUTPUT = 100
DBG_DETAIL = 120
DBG_CALL1 = 150
DBG_CALL2 = 160
DBG_CALL3 = 170
DBG_TOOLSDETAIL = 190
DBG_EXTROVERT = 200
DBG_PARAMS = 230
DBG_VERBOSE = 255
BUILD_DEBUG = DBG_CALL2






#
# Orchestration
#

makeClean = ARG2=='clean'
makeAll = (ARG2=='all') or (ARG3=='all')
makeFinished = False

configure_target()
configure_verbose_parameters()
configure_build_events()
opening()
filesystem_settings()
build_events_settings()
#exec_action(build start %BUILD_START_ACTION%)
create_dir_struct()
house_cleaning()
application_settings()

if MDO_SUPPORT==1:
    mdo_settings()

if makeClean:
    clean()
    finished = not makeAll

if not finished:
    collect_include_dirs()
#    exec_action (before compile %BEFORE_COMPILE_ACTION%)

    if all:
        build_lib

    compile_project
#   exec_action (after compile $AFTER_COMPILE_ACTION)
    build_msx_bin
#   exec_action (after binary $AFTER_BINARY_ACTION)

# exec_action (build end %BUILD_END_ACTION%)
finish()

exit 0