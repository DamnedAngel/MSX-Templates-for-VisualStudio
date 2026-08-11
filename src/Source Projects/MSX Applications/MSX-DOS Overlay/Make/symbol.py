import string
import sys
import re
from os import path

argc = len(sys.argv)

if argc < 4:
	exit (-1)

mdo = (sys.argv[1] == 'DOS') or (sys.argv[1] == 'MDO')
verbose = False
if argc >= 5:
	verbose = sys.argv[4] == '-v'

###################################
# Load symbol patterns
###################################
patterns = []
with open('Config/Symbols.txt', 'r') as f1:
	for line in f1:
		line1 = line.strip()
		words = line1.split()
		l = len (words)
		if l > 0:
			if line1[0] != ';':
				if l > 2:
					patterns.append ([words[0], words[1], words[2]])
				else:
					patterns.append ([words[0],'',''])
				if verbose:
					print ('Loaded pattern ' + words[0] + '.')

f1.close()

###################################
# Write symbol files
###################################
f2 = open(path.join(sys.argv[2], sys.argv[3]) + '_.sym', 'w')
if mdo:
	f3 = open(path.join(sys.argv[2], 'parentinterface') + '.s', 'w')
	f4 = open(path.join(sys.argv[2], 'parentinterface') + '.h', 'w')
	f4.write('#pragma once\n')
	f5 = open(path.join(sys.argv[2], 'MODULE_AFTERHEAP'), 'w')


with open(path.join(sys.argv[2], sys.argv[3]) + '.noi', 'r') as f1:
	for line in f1:
		line1 = line.strip()
		words = line1.split()
		if len(words) > 2:
			if words[0] == "DEF":
				value = words[2][2:]
				if verbose:
					print ('Found line: ' + line1)
				# OpenMSX Symbol file
				if words[1].find('$') == -1:
					f2.write(words[1] + ': equ ' + value + 'H\n')
				# MDO MODULE_AFTERHEAP
				if (mdo):
					if (words[1] == 's__AFTERHEAP'):
						f5.write("0x" + value)
					for pattern in patterns:
						if re.match(pattern[0], words[1]):
							symbol = re.sub(pattern[1], pattern[2], words[1])
							# ASM Symbol file
							f3.write(symbol + ' 			.gblequ 0x' + value + '\n')
							# Header Symbol file
							f4.write("#define " + symbol + '			0x' + value + '\n')
							if verbose:
								print ('Exported symbol ' + symbol + '(' + words[1] + ') = 0x' + value + '.')
f1.close()
f2.close()
if mdo:
	f3.close()
	f4.close()
	f5.close()

exit()
