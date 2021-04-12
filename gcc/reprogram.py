#!/usr/bin/python3

import serial
import binascii
# import sys
import argparse 

parser = argparse.ArgumentParser()
parser.add_argument('hexfile', nargs='?', help='hex file to program board')
parser.add_argument('-p', '--port', type=str, default='/dev/ttyUSB1', help='serial port')
args = parser.parse_args()

# port = '/dev/ttyUSB1'
baudrate = 115200

ser = serial.Serial(args.port, baudrate)
ser.bytesize = serial.EIGHTBITS
ser.timeout = 2;

# raw_input("Make sure that the PROG switch is set before programming!")
# input("Make sure that the PROG switch is set before programming!")
input("Press Enter to Begin")

print(args.hexfile)
f = open(args.hexfile, 'r')
ins = f.readlines() 
#ins=ins[2:-1]
deadbeef = 'deadbeef'
# baddab99 = 'baddab99'

for i in range(len(deadbeef)-1, -1, -2):
	tx = deadbeef[i-1:i+1]
	tx = binascii.unhexlify(tx)
	ser.write(bytes(tx));

for l in ins:
	l = l[:-1]
	print(l)
	for i in range(len(l)-1, -1, -2):
		tx = l[i-1:i+1]
		tx = binascii.unhexlify(tx)
		ser.write(bytes(tx));

for i in range(len(deadbeef)-1, -1, -2):
	tx = deadbeef[i-1:i+1]
	tx = binascii.unhexlify(tx)
	ser.write(bytes(tx));

# for i in range(len(baddab99)-1, -1, -2):
# 	tx = baddab99[i-1:i+1]
# 	tx = binascii.unhexlify(tx)
# 	ser.write(bytes(tx));

while(1):
	rcv = ser.read()
	print(rvc.decode())
