from Crypto.Util.number import *
from secret import flag

assert flag[:5]=='cnss{' and flag[-1] == '}'

flag_k = bytes_to_long(flag[5:-1].encode())

p = 1096126227998177188652856107362412783873814431647
a = 0
b = 5
E = EllipticCurve(GF(p), [a, b])

assert E.order() == p 
base_point = E(626099523290649705896889901241128842906228328604,886038875771695334071307095455656761758842526929)

assert base_point in E
assert flag_k < p 

Q = flag_k*base_point
print(Q)

# (240653647745552223089451307742208085297121769374 : 1041806436100548540817642210994295951394712587396 : 1)