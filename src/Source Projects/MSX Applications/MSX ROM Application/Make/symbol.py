import string
import sys
from os import path

def is_hex(s):
	try:
		int(s, 16)
		return True
	except ValueError:
		return False

f1 = open(path.join(sys.argv[1], sys.argv[2]) + '_.sym', 'w')

with open(path.join(sys.argv[1], sys.argv[2]) + '.map', 'r') as f2:
	for line in f2:
		line1 = line.strip()
		words = line1.split()
		if len(words) > 1:
			if is_hex(words[0]):
				f1.write(words[1] + ': equ ' + words[0] + "H\n")

f1.close()

exit()
