#!/usr/bin/env python3

# ============================================================
# ADB Generator Script
#
# Usage:
#   python Make/adbgenerator.py [-v] [-I path] <PROJECT_TYPE> <OBJ_PATH/> <FILE_NAME>
#
# PROJECT_TYPE: (currently unused)
# OBJ_PATH:     path to object/output folder
# FILE_NAME:    base filename (no extension)
# -v:           verbose output
# -I path:      additional include directories (can be repeated)
#
# Reads:
#   <OBJ_PATH>/<FILE_NAME>.map   Linker map (module order + section bases)
#   <OBJ_PATH>/*.lst             Assembler listings (line → relative address)
#   <OBJ_PATH>/*.rel             Object files (module _CODE sizes)
#   Source files (.s/.asm)       Resolved via include paths
#
# Writes:
#   <OBJ_PATH>/<FILE_NAME>.relmap.tmp   file:line → relative address
#   <OBJ_PATH>/<FILE_NAME>.relmap       file:line → absolute address
#
# Description:
#   Reconstructs source line → Z80 address mapping for SDCC/ASxxxx builds.
#
#   - Uses .lst files as primary source of line ↔ relative address
#   - Resolves source files via .include directives
#   - Matches lines strictly by (line number + source text)
#   - Uses MRU (recency list) to resolve ambiguities
#   - Computes absolute addresses using .map + .rel layout
#
# Limitations:
#   - Macro expansions are skipped (no reliable mapping)
#   - Requires line-number consistency between .lst and source files
#   - No fuzzy matching or file scanning (strict resolution only)
#   - One mapping per (file, line); duplicates are ignored
# ============================================================

import os
import sys
import re
from collections import defaultdict

verbose = False

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

def log(header, msg, force = False):
    if verbose or force:
        print(f"{header}: {msg}")

def warning (header, msg):
    log (header, f"***WARNING*** {msg}", True)

def error (header, msg):
    log (header, f"***ERROR*** {msg}", True)

def norm_path(p):
    # Convert Windows-style separators to current OS
    p = p.replace("\\", os.sep).replace("/", os.sep)
    return os.path.normpath(os.path.abspath(p))


def parse_hex(s):
    return int(s, 16)


# ------------------------------------------------------------
# MAP PARSER
# ------------------------------------------------------------

def parse_map(map_path):
    modules = []
    code_base = 0

    in_files = False
    in_libs = False

    with open(map_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.rstrip()

            # _CODE base
            m = re.search(r'_CODE\s*=\s*0x([0-9A-Fa-f]+)', line)
            if m:
                code_base = int(m.group(1), 16)

            if "Files Linked" in line:
                in_files = True
                in_libs = False
                continue

            if "Libraries Linked" in line:
                in_files = False
                in_libs = True
                continue

            if in_files or in_libs:
                m = re.match(r'\s*([^\s]+\.rel)', line)
                if m:
                    mod = os.path.basename(m.group(1))
                    modules.append(mod)

    log(f"[MAP]", f"_CODE base: 0x{code_base:04X}")
    log(f"[MAP]", f"Module order: {modules}")

    return code_base, modules


# ------------------------------------------------------------
# REL PARSER
# ------------------------------------------------------------

def parse_rel_sizes(obj_path, modules):
    sizes = {}

    for mod in modules:
        rel_path = os.path.join(obj_path, mod)
        size = 0

        if not os.path.exists(rel_path):
            warning("f[REL {mod}]", f"{rel_path} not found. Assuming size 0.")
            sizes[mod] = 0
            continue

        with open(rel_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if line.startswith("A _CODE"):
                    m = re.search(r'size\s+([0-9A-Fa-f]+)', line)
                    if m:
                        size = int(m.group(1), 16)
                        break

        sizes[mod] = size
        log(f"[REL {mod}]", f": _CODE size = 0x{size:04X}")

    return sizes


# ------------------------------------------------------------
# LST PARSER
# ------------------------------------------------------------

def getAddrAndSrcLine(lstLine):
    if len(lstLine) < 39:
        return False, None, None

    # address (columns 6–11)
    addrStr = lstLine[6:12]
    if not re.match(r'[0-9A-Fa-f]{6}', addrStr):
        return False, None, None
    try:
        addr = int(addrStr, 16)
    except:
        return False, None, None

    # source line:
    # scan backwards from column 39 (index 38) to find last non-digit
    i = 38
    while i >= 0 and lstLine[i].isdigit():
        i -= 1

    srcLineStr = lstLine[i+1:39]
    if not srcLineStr:
        return False, None, None

    try:
        srcLine = int(srcLineStr)
    except:
        return False, None, None

    return True, addr, srcLine

def hasHexBytes(lstLine):
    if len(lstLine) < 16:
        return False

    # columns 13–14 must be hex digits
    if not (lstLine[13] in "0123456789ABCDEFabcdef" and
            lstLine[14] in "0123456789ABCDEFabcdef"):
        return False

    # column 15 must be space
    if lstLine[15] != ' ':
        return False

    return True

def extract_source(lstLine):
    if len(lstLine) < 40:
        return ""
    return lstLine[40:].rstrip('\n')


# ------------------------------------------------------------
# SOURCE CACHE
# ------------------------------------------------------------

class SourceCache:
    def __init__(self, include_dirs):
        self.cache = {}
        self.include_dirs = include_dirs
        self.verbose = verbose

    def load(self, filename):
        for base in self.include_dirs:
            path = norm_path(os.path.join(base, filename))
            if os.path.exists(path):
                if path not in self.cache:
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        self.cache[path] = f.readlines()
                    log(f"[SRC]", f"Loaded {path}")
                return path

        log(f"[SRC]", f"Include not found: {filename}")
        return None


# ------------------------------------------------------------
# LST PROCESSOR
# ------------------------------------------------------------

def process_lst(lst_path, module_name, cache):
    mapping = []  # (file, line, rel addr)

    # root file
    base = os.path.splitext(os.path.basename(lst_path))[0]
    root_candidates = [base + ".s", base + ".asm"]

    root_file = None
    for rc in root_candidates:
        root_file = cache.load(rc)
        if root_file:
            break

    if not root_file:
        warning(f"[LST {base}]", f"Root file not found for {lst_path}")
        return mapping

    root_lines = cache.cache.get(root_file)
    if not root_lines:
        warning(f"[LST {base}]", f"Failed to load source lines for {root_file}")
        return mapping

    with open(lst_path, 'r', encoding='utf-8', errors='ignore') as f:
        lstLines = f.readlines()

    current_area = "_CODE"  # default (safe assumption)

    for lstIdx, lstLine in enumerate(lstLines):
        logPrefix = f"[LST {base},{lstIdx+1}] "

        # detect area change
        area_match = re.search(r'\.area\s+([A-Za-z0-9_]+)', lstLine)
        if area_match:
            current_area = area_match.group(1)
            log(f"{logPrefix}", f"Switched to area {current_area}")
            continue

        hasAddr, relAddr, srcLineNo = getAddrAndSrcLine(lstLine)
        if not hasAddr or relAddr is None or srcLineNo is None:
            continue

        src = extract_source(lstLine).lstrip()
        if not src:
            continue

        tgtIdx = srcLineNo-1
        log(f"{logPrefix}", f"Checking {root_file}:{srcLineNo}")
        if tgtIdx < 0 or tgtIdx >= len(root_lines):
            warning(f"{logPrefix}", f"{srcLineNo} beyond EoF!!! Skipping")
            continue

        file_line = root_lines[tgtIdx].lstrip()

        log(f"{logPrefix}", f"Compare src: {src}")
        log(f"{logPrefix}", f"Compare tgt: {file_line}")

        if not file_line.startswith(src):
            warning(f"{logPrefix}", f"Line text does not match root file. Skipping.")
            continue

        log(f"{logPrefix}", f"Line matched!")

        # has addr and source line matches root file.
        if not hasHexBytes(lstLine):
            # may be a macro call, a lone label or other directives.
            # test if source line number for next line is 1.
            # If so, register line on mapping

            macroFound = False
            i = 1
            while not macroFound:

                if lstIdx + i >= len(lstLines):
                    break

                nextLine = lstLines[lstIdx+i]
                nextHasAddr, _, nextSrcLineNo = getAddrAndSrcLine(nextLine)
                if nextHasAddr:
                    if nextSrcLineNo == 1:
                        macroFound = True
                    else:
                        break
                i += 1

            if not macroFound:
                continue

        mapping.append((root_file, srcLineNo, current_area, relAddr))

    return mapping


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------

def main():
    global verbose

    if len(sys.argv) < 4:
        print("Usage: adbgenerator.py [-v] [-I path] <PROJECT_TYPE> <OBJ_PATH> <FILE_NAME>")
        sys.exit(1)

    args = []
    i = 1
    argv = sys.argv

    while i < len(argv):
        arg = argv[i]

        if arg == "-v":
            i += 1
            continue

        if arg.startswith("-I"):
            if arg == "-I":
                i += 2
            else:
                i += 1
            continue

        args.append(arg)
        i += 1

    if len(args) < 3:
        print("Usage: python Make/adbgenerator.py [-v] [-I path] <PROJECT_TYPE> <OBJ_PATH> <FILE_NAME>")
        sys.exit(1)

    project_type = args[0]
    obj_path = args[1]
    file_name = args[2]

    verbose = "-v" in sys.argv

    include_dirs = [norm_path(os.getcwd()), norm_path(obj_path)]

    i = 0
    argv = sys.argv

    while i < len(argv):
        arg = argv[i]

        # Case 1: -I"path" or -Ipath
        if arg.startswith("-I") and len(arg) > 2:
            path = arg[2:]

            # Strip quotes if present
            if (path.startswith('"') and path.endswith('"')) or \
               (path.startswith("'") and path.endswith("'")):
                path = path[1:-1]

            include_dirs.append(path)
            i += 1
            continue

        # Case 2: -I "path"
        if arg == "-I":
            if i + 1 >= len(argv):
                print("Error: -I requires a path")
                sys.exit(1)

            path = argv[i + 1]

            if (path.startswith('"') and path.endswith('"')) or \
               (path.startswith("'") and path.endswith("'")):
                path = path[1:-1]

            include_dirs.append(path)
            i += 2
            continue

        i += 1

    include_dirs = [norm_path(p) for p in include_dirs]

    map_path = os.path.join(obj_path, file_name + ".map")

    code_base, modules = parse_map(map_path)
    sizes = parse_rel_sizes(obj_path, modules)

    # compute module bases
    module_base = {}
    current = code_base

    for mod in modules:
        module_base[mod] = current
        current += sizes.get(mod, 0)

    log(f"[LINK]", f"Module bases: {module_base}")

    cache = SourceCache(include_dirs)

    global_tmp = {}
    global_final = {}

    for mod in modules:
        lst_name = os.path.splitext(mod)[0] + ".lst"
        lst_path = os.path.join(obj_path, lst_name)

        if not os.path.exists(lst_path):
            continue

        log(f"[LST]", f"Processing {lst_path}")

        mapping = process_lst(lst_path, mod, cache)

        for file, line, area, rel in mapping:
            key = f"{os.path.basename(file)}:{line}"
            area_key = f"{area}:{rel:06X}"

            if area_key not in global_tmp:
                global_tmp[area_key] = (key, rel)

            if area == "_CODE" or area.startswith ("_HEADER"):
                abs_addr = module_base[mod] + rel

                if abs_addr not in global_final:
                    global_final[abs_addr] = (key, abs_addr)

    # write outputs
    tmp_path = os.path.join(obj_path, file_name + ".relmap.tmp")
    final_path = os.path.join(obj_path, file_name + ".adb")

    with open(tmp_path, "w") as f:
        for k, (fileline, rel) in sorted(global_tmp.items(), key=lambda x: x[1][1]):
            f.write(f"{k} -> {fileline} @ 0x{rel:04X}\n")
    log(f"[OUT]", f"Written {tmp_path}", True)

    with open(final_path, "w") as f:
        for k, (fileline, abs_addr) in sorted(global_final.items(), key=lambda x: x[1][1]):
            filename, line = fileline.split(":")
            filename = os.path.splitext(filename)[0]

            f.write(f"L:A${filename}${line}:{abs_addr:04X}\n")
    log(f"[OUT]", f"Written {final_path}", True)


if __name__ == "__main__":
    main()
