import sys
import os

basestr = 'memory_initialization_radix=16;\nmemory_initialization_vector=\n'
#basedir = 'C:/Users/grayb/Projects/Mini-Risc-V-Uart-Srcs/gcc/'
basedir = 'C:/Users/bserg_000/Documents/Source/ReturnAddressEncryption/Mini-Risc-V-Uart-Srcs/gcc/'

mems = [list(), list(), list(), list()] 

with open(sys.argv[1], 'r') as f:
	lines = f.readlines() 
	for l in lines:
		l = l.strip('\n')
		mems[0].append(l[6:8])
		mems[1].append(l[4:6])
		mems[2].append(l[2:4])
		mems[3].append(l[0:2])

idx = 0
outfile_base = os.path.splitext(sys.argv[1])[0]
for m in mems:
	outfilestr = outfile_base + str(idx) + '.coe'
	with open(outfilestr, 'w') as f:
		f.write(basestr)
		for b in m:
			f.write(b + '\n')
		f.write(';')
	idx += 1

with open('loadcoe_base.tcl', 'r') as f:
	coescript = f.read() 

for i in range(4):
	outfilestr = basedir + outfile_base + str(i) + '.coe'
	coescript = coescript.replace('%' + str(i), outfilestr)

with open('loadcoe.tcl', 'w') as f:
	f.write(coescript)

