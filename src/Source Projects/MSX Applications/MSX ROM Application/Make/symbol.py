import string
import sys
import re
from os import path

argc = len(sys.argv)

if argc < 3:
	exit (-1)

verbose = False
if argc >= 4:
	verbose = sys.argv[3] == '-v'

def is_hex(s):
	try:
		int(s, 16)
		return True
	except ValueError:
		return False

###################################
# Load symbol patterns
###################################
patterns = []
with open('Symbols.txt', 'r') as f1:
	for line in f1:
		line1 = line.strip()
		words = line1.split()
		if len(words) == 1:
			if line1[0] != ';':
				patterns.append(line1)
				if verbose:
					print ('Loaded pattern ' + line1 + '.')

f1.close()

###################################
# Write symbol files
###################################
f2 = open(path.join(sys.argv[1], sys.argv[2]) + '_.sym', 'w')
f3 = open(path.join(sys.argv[1], sys.argv[2]) + '.s', 'w')
f4 = open(path.join(sys.argv[1], sys.argv[2]) + '.h', 'w')
f4.write('#pragma once\n')

with open(path.join(sys.argv[1], sys.argv[2]) + '.map', 'r') as f1:
	for line in f1:
		line1 = line.strip()
		words = line1.split()
		if len(words) > 1:
			if is_hex(words[0]):
				# OpenMSX Symbol file
				f2.write(words[1] + ': equ ' + words[0] + 'H\n')
				for pattern in patterns:
					if re.match(pattern, words[1]):
						value = words[0][3:]
						# ASM Symbol file
						f3.write(words[1] + ': 			equ 0x' + value + '\n')
						# Header Symbol file
						f4.write("#define " + words[1] + '			0x' + value + '\n')
						if verbose:
							print ('Exported symbol ' + words[1] + ' (0x' + value + ').')
f1.close()
f2.close()
f3.close()
f4.close()

exit()
