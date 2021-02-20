import serial
import binascii
import random
import pandas as pd

port = serial.Serial("COM7", baudrate=115200)
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
    #print(retval)
    #print(cnt)
    return retval, cnt

def fact_test(n, en):
    send_byte(en)
    send_int(n)
    val = recv_byte()
    cnt = recv_byte()
    print(n)
    print(cnt)
    return val, cnt

def fact_multi_test(n_lower, n_upper):
    n_list = range(n_lower, n_upper)
    c0_list = list()
    c0_val = list()
    c1_list = list()
    c1_val = list()
    for n in n_list:
        c0 = fact_test(n, 0)
        c1 = fact_test(n, 1)
        c0_list.append(c0[1])
        c1_list.append(c1[1])
        c0_val.append(c0[0])
        c1_val.append(c1[0])

    df = pd.DataFrame({"n": n_list, "c0": c0_list, "c0_val":c0_val,
                       "c1": c1_list, "c1_val":c1_val})



    print(df)

    df.to_csv('new_fact.csv')

def check_array(arr):
    for i in range(1, len(arr)):
        if (arr[i] < arr[i-1]):
            return 0
    return 1
    

def multi_test():
    rept = 512
    #arr_len = 64
    len_list = list()
    c0_list = list()
    c0_val = list()
    c1_list = list()
    c1_val = list()
    for arr_len in range(32, 520, 8):
        print("Array size: %d" % arr_len)
        for i in range(rept):
            arr = list()
            len_list.append(arr_len)
            for j in range(arr_len):
                #arr.append(arr_len - j)
                arr.append(random.randint(0, 4096))

            (a0, c0) = run_test(arr, arr_len, 0)
            (a1, c1) = run_test(arr, arr_len, 1)
            if not check_array(a0):
                print("ERROR")
                break
            if not check_array(a1):
                print("ERROR")
                break
            print("%d:\n0: %d\n1: %d\n" % (i, c0, c1))
            c0_list.append(c0)
            c1_list.append(c1)
        

        df = pd.DataFrame({"len": len_list, "c0": c0_list,
                       "c1": c1_list})

    #print(df)
        df.to_csv('new_test64.csv')


multi_test()


#fact_multi_test(3, 100)
