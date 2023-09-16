from secret import flag
from Crypto.Util.number import bytes_to_long, getRandomNBitInteger
from random import getrandbits
from os import urandom

assert flag.startswith(b'cnss{I_a') and flag.endswith(b'}')
assert len(flag)%8==0
MASK1 = getRandomNBitInteger(32)|(0xffffffff00000000)
MASK2 = getRandomNBitInteger(32)<<32
ROUND = 5
def genKey():
    tmp = []
    for i in range(ROUND):
        tmp.append(getRandomNBitInteger(64))
def NotHomoFunction(x,iv,key):
    return ((x<<iv)&MASK1)^((x>>iv)|MASK2)^key

def encrypt(message,iv,key):
    cipher = bytes_to_long(message)
    for i in range(ROUND):
        cipher = NotHomoFunction(cipher,iv,key)
    return cipher

cipher = []
iv = 32
key = getRandomNBitInteger(64)
for i in range(0,len(flag),8):
    cipher.append(encrypt(flag[i:i+8],iv,key))

print(cipher)
print(iv)
print(MASK2)



""" 
[4840951631397558164, 5492303526413306583, 6271460196030786735, 6127905759336302986, 601209385465514967]
32
16500653344889503744
"""