import serial
import binascii

port = serial.Serial("COM4", baudrate=115200)

def send_int(a):
    port.write(a.to_bytes(4, byteorder='little'))

def send_byte(a):
    c = a & 0xff
    port.write(c.to_bytes(1, byteorder='little'))

def recv_byte():
    return int.from_bytes(port.read(4), byteorder='little')

def run_test(arr, arr_len, en):
    send_byte(en)
    send_int(arr_len)
    for a in arr:
        send_int(a)

    retval = list()
    tmp = 0
    for i in range(arr_len):
        retval.append(recv_byte())
        send_byte(0)
    cnt = recv_byte() 
    print(retval)
    print(cnt)
    


arr_len = 64;
arr = list()

for i in range(arr_len):
    arr.append(arr_len - i)

run_test(arr, arr_len, 0)
run_test(arr, arr_len, 1)


# char = bytes('a')
# port.write(char)
# rcv=port.read()
# print(rcv.decode())
