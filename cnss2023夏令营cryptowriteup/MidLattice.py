import hashlib
from Crypto.Util.number import *
pbit = 500
qbit = 550
rbit = 200
def get_sample():
    x_list  = []
    p = getPrime(pbit)
    for i in range(120):
        q = getPrime(qbit)
        r = getPrime(rbit)
        x_list.append(q*p + 2*r)
    return x_list,p
sample,p = get_sample()
flag = 'cnss{'+hashlib.sha256(long_to_bytes(p)).hexdigest()+'}'
with open("output.txt", "w") as file:
    file.write(str(sample))
