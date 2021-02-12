import serial
import binascii

port = serial.Serial("COM7", baudrate=115200)

a = 0x00112233; 

port.write(a.to_bytes(4))
rcv = port.read();

# char = bytes('a')
# port.write(char)
# rcv=port.read()
# print(rcv.decode())