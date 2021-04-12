import serial
import binascii

port = serial.Serial("COM7", baudrate=115200)

char = bytes('a')
port.write(char)
rcv=port.read()
print(rcv.decode())