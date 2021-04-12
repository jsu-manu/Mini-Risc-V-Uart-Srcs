#!/usr/bin/python3
import os 
import argparse 

def runbash(cmd):
	exitCode = os.system(cmd)
	if (exitCode > 0):
		print("ERROR :(")
		exit()

def prep_hex(filename, iscoe=True):
	b = open(filename + '.bin', 'rb').read() 
	i = 0 
	ext = '.hex'
	if (iscoe):
		ext = '.coe'
	f = open(filename + ext, 'w')
	if (iscoe):
		f.write('memory_initialization_radix=16;\nmemory_initialization_vector=\n')
	while(i < len(b)):
		btmp = b[i:i+4]
		hexstr = ''
		for t in btmp:
			hexstr = f'{t:0{2}x}' + hexstr
			# hexstr = hex(t)[2:] + hexstr
		f.write(hexstr + '\n')
		i += 4 
	if (iscoe):
		f.write(';')
	f.close() 




parser = argparse.ArgumentParser()
parser.add_argument('files', nargs='+', help='File Names (Takes .c and .s')
# parser.add_argument('-c', '--coe', action='store_true', help='generate .coe file instead of .hex file')
parser.add_argument('-x', '--hex', action='store_true', help='generate .hex instead of .coe file')
parser.add_argument('-s', '--save_temps', action='store_true', help='save intermediate .s and .o files')
parser.add_argument('-l', '--linker_script', type=str, default='minirisc.ld')
parser.add_argument('-b', '--bootloader', type=str, default='boot.S')
parser.add_argument('-o', '--output', type=str, default='a.hex')
parser.add_argument('-k', '--compile_kernel', action='store_true')
args = parser.parse_args()

cmd = 'riscv32-unknown-elf-gcc -nostdlib -O0 -Wl,-T,' + args.linker_script + ' -o ' #',-e,0 -o '
dmp = 'riscv32-unknown-elf-objdump -d '

# asm = 'heapthing.S'

if (args.compile_kernel):
	args.linker_script = 'kernel.ld'
	args.bootloader = 'kboot.S' 

if ('.coe' in args.output):
	args.output = args.output.replace('.coe', '')
if ('.hex' in args.output):
	args.output = args.output.replace('.hex', '')	

cmd += (args.output + '.elf ')
cmd += args.bootloader
# cmd += (' ' + asm)
for f in args.files:
	cmd += (' ' + f)

# print(cmd)

# exitCode = os.system(cmd)
# if (exitCode > 0):
# 	print("ERROR :(")
# 	exit()
runbash(cmd) 

cmd2 = 'riscv32-unknown-elf-objcopy -O binary ' + args.output + '.elf' + ' ' + args.output + '.bin'

runbash(cmd2)

prep_hex(args.output, iscoe = not(args.hex))

if (args.save_temps):
	runbash(dmp + args.output + '.elf > ' + args.output + '.dump')
