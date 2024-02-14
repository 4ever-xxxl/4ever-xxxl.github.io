from random import shuffle, getrandbits
from secret import flag
from Crypto.Util.number import *
Zx = PolynomialRing(ZZ, 'x')
x = Zx.gen()


def convolution(f, g, R):
    return (f * g) % R


def balancedmod(f, q, R):
    g = list(map(lambda x: ((x + q//2) % q) - q//2, f.list()))
    return Zx(g) % R


def random_poly(n, d1, d2):
    assert d1 + d2 <= n
    result = d1 * [1] + d2 * [-1] + (n - d1 - d2) * [0]
    shuffle(result)
    return Zx(result)


def invert_poly_mod_prime(f, R, p):
    T = Zx.change_ring(Integers(p)).quotient(R)
    return Zx(lift(1 / T(f)))


def invert_poly_mod_powerof2(f, R, q):  # Hensel Lemma 
    g = invert_poly_mod_prime(f, R, 2)
    e = log(q, 2)
    for i in range(1, e):
        g = ((2 * g - f * g ** 2) % R) % q
    return g


class NTRUCipher:
    def __init__(self, N, p, q, d):
        self.N = N
        self.p = p
        self.q = q
        self.d = d
        self.R = x ** N - 1
        # key generation
        self.g = random_poly(self.N, d, d)
        
        while True:
            try:
                self.f = random_poly(self.N, d + 1, d)
                self.fp = invert_poly_mod_prime(self.f, self.R, self.p)
                self.fq = invert_poly_mod_powerof2(self.f, self.R, self.q)
                break
            except:
                pass

        self.h = balancedmod(self.p * convolution(self.fq, self.g, self.R), self.q, self.R)
    def getPubKey(self):
        return self.h
    def encrypt(self, m):
        r = random_poly(self.N, self.d, self.d)
        return balancedmod(convolution(self.h, r, self.R) + m, self.q, self.R)

    def decrypt(self, c):
        a = balancedmod(convolution(c, self.f, self.R), self.q, self.R)
        return balancedmod(convolution(a, self.fp, self.R), self.p, self.R)

    def encode(self, val):
        poly = 0
        
            poly += ((val % self.p) - self.p // 2) * (x ** i)
            val //= self.p
        return poly

    def decode(self, poly):
        result = 0
        ll = poly.list()
        for idx, val in enumerate(ll):
            result += (val + self.p // 2) * (self.p ** idx)
        return result

    def poly_from_list(self, l: list):
        return Zx(l)


if __name__ == '__main__':
    N = 160
    d = 30
    p = 3
    q = 65536

    cipher = NTRUCipher(N, p, q, d) 
    print("[PubKey]---------")
    h = cipher.getPubKey()
    print(f'h = {h}')
    msg = bytes_to_long(flag)
    encode_msg = cipher.encode(msg)
    c = cipher.encrypt(encode_msg)
    print("[Cipher]---------")
    print(f'c = {c}')
    mm = cipher.decrypt(c)
    decode_msg = cipher.decode(mm)
    assert decode_msg == msg
    
    
'''
[PubKey]---------
h = -11891*x^159 + 16347*x^158 - 32137*x^157 + 14988*x^156 + 16657*x^155 - 25785*x^154 - 21976*x^153 - 31745*x^152 - 4232*x^151 + 29569*x^150 + 27140*x^149 + 19617*x^148 - 16656*x^147 + 8925*x^146 + 8728*x^145 - 8802*x^144 - 10794*x^143 - 28159*x^142 - 6454*x^141 - 10259*x^140 - 19169*x^139 - 14357*x^138 + 3501*x^137 + 9885*x^136 - 7441*x^135 + 18268*x^134 - 27183*x^133 + 26085*x^132 + 19147*x^131 + 17153*x^130 - 22887*x^129 + 32476*x^128 - 21698*x^127 + 19138*x^126 + 11585*x^125 + 22755*x^124 - 5920*x^123 + 7581*x^122 + 25973*x^121 + 13787*x^120 - 22762*x^119 + 29207*x^118 - 17916*x^117 - 11502*x^116 + 18275*x^115 + 318*x^114 - 6890*x^113 - 22751*x^112 - 27677*x^111 - 11114*x^110 + 8623*x^109 - 15725*x^108 - 6835*x^107 - 8288*x^106 - 5235*x^105 - 28697*x^104 + 10696*x^103 + 17117*x^102 + 24696*x^101 - 7801*x^100 - 31874*x^99 - 17668*x^98 - 11204*x^97 + 19147*x^96 + 24644*x^95 - 29380*x^94 - 26237*x^93 - 27390*x^92 + 19982*x^91 + 4074*x^90 - 17248*x^89 - 11027*x^88 - 32690*x^87 + 5124*x^86 - 20823*x^85 - 11779*x^84 + 13781*x^83 + 29356*x^82 - 9740*x^81 - 31484*x^80 - 540*x^79 + 32360*x^78 + 24795*x^77 - 8864*x^76 + 17363*x^75 + 9670*x^74 + 32268*x^73 + 17961*x^72 + 6388*x^71 + 580*x^70 + 128*x^69 + 339*x^68 + 3412*x^67 - 4519*x^66 - 25056*x^65 + 6096*x^64 + 18720*x^63 - 5338*x^62 + 16910*x^61 + 3353*x^60 + 15433*x^59 - 28053*x^58 - 18883*x^57 + 7688*x^56 - 31198*x^55 + 9950*x^54 - 9388*x^53 + 21235*x^52 + 2847*x^51 + 24383*x^50 + 19431*x^49 + 21244*x^48 - 8498*x^47 - 28998*x^46 + 962*x^45 + 20579*x^44 + 28002*x^43 - 6040*x^42 + 4241*x^41 + 11655*x^40 - 32419*x^39 + 21531*x^38 + 7348*x^37 - 5503*x^36 + 29820*x^35 + 28896*x^34 + 8754*x^33 + 17978*x^32 + 7552*x^31 + 27240*x^30 - 29515*x^29 - 20322*x^28 + 2201*x^27 + 8857*x^26 - 50*x^25 - 3780*x^24 - 12138*x^23 + 10893*x^22 + 23133*x^21 + 6142*x^20 - 23798*x^19 - 15236*x^18 + 32564*x^17 + 25683*x^16 - 24010*x^15 - 4355*x^14 + 22552*x^13 - 27155*x^12 + 27649*x^11 + 17781*x^10 + 7115*x^9 + 27465*x^8 - 4369*x^7 + 24882*x^6 - 11675*x^5 - 612*x^4 + 12361*x^3 + 20120*x^2 + 6190*x - 10843
[Cipher]---------
c = -26801*x^159 - 25103*x^158 + 29811*x^157 - 12251*x^156 - 13386*x^155 - 28030*x^154 - 16511*x^153 + 23761*x^152 + 28329*x^151 - 16406*x^150 + 30931*x^149 + 5326*x^148 + 19877*x^147 - 23165*x^146 - 31540*x^145 - 7923*x^144 + 5880*x^143 - 27078*x^142 - 25436*x^141 - 17162*x^140 + 1471*x^139 + 14486*x^138 + 7702*x^137 - 29890*x^136 + 29315*x^135 + 558*x^134 - 22429*x^133 - 361*x^132 + 19049*x^131 - 30437*x^130 - 32610*x^129 - 3024*x^128 - 4313*x^127 + 29174*x^126 - 2837*x^125 - 2812*x^124 + 13450*x^123 - 15001*x^122 - 25791*x^121 - 8702*x^120 - 4968*x^119 - 15340*x^118 + 31744*x^117 - 32478*x^116 + 19737*x^115 - 12629*x^114 - 27847*x^113 + 27322*x^112 - 31375*x^111 + 14777*x^110 + 29825*x^109 - 25883*x^108 - 13335*x^107 + 32517*x^106 + 14871*x^105 - 7287*x^104 + 13398*x^103 - 32710*x^102 + 20805*x^101 + 29734*x^100 - 14579*x^99 + 17483*x^98 - 16864*x^97 - 26745*x^96 + 3254*x^95 + 7280*x^94 - 29046*x^93 - 7531*x^92 - 8791*x^91 + 15033*x^90 - 1125*x^89 - 14713*x^88 - 12273*x^87 + 8616*x^86 + 2486*x^85 + 31810*x^84 + 27795*x^83 - 21731*x^82 + 21743*x^81 - 27595*x^80 - 3592*x^79 - 27206*x^78 - 32156*x^77 + 32124*x^76 - 11212*x^75 - 6662*x^74 - 23103*x^73 - 3660*x^72 - 31043*x^71 - 17131*x^70 + 24544*x^69 - 32326*x^68 - 31047*x^67 + 19814*x^66 + 10874*x^65 - 8449*x^64 + 11744*x^63 + 2245*x^62 - 967*x^61 + 9120*x^60 + 8983*x^59 - 24573*x^58 + 24885*x^57 + 15649*x^56 - 18970*x^55 + 7354*x^54 - 12282*x^53 - 22474*x^52 + 4395*x^51 + 8428*x^50 - 32592*x^49 + 25980*x^48 - 4599*x^47 + 16310*x^46 + 18559*x^45 + 22897*x^44 + 19080*x^43 - 26065*x^42 - 9*x^41 + 29202*x^40 + 2121*x^39 - 5004*x^38 + 5299*x^37 - 28301*x^36 - 13519*x^35 + 24241*x^34 + 529*x^33 - 20574*x^32 - 27391*x^31 + 31976*x^30 + 22824*x^29 - 31410*x^28 - 20976*x^27 + 21661*x^26 - 15132*x^25 + 1905*x^24 - 30870*x^23 + 18109*x^22 - 17373*x^21 + 5342*x^20 - 22447*x^19 + 1893*x^18 - 17545*x^17 + 30097*x^16 - 21731*x^15 + 17390*x^14 + 10991*x^13 - 5384*x^12 + 15960*x^11 + 24268*x^10 - 29867*x^9 + 22532*x^8 + 10133*x^7 - 26576*x^6 - 5742*x^5 - 16252*x^4 + 13019*x^3 - 25984*x^2 + 14004*x + 22500

'''