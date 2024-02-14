# CNSS2023夏令营_Crypto_Writeup

『来玩洛克王国谢谢喵』的 Crypto 之旅.
<!--more-->


## 🌀 cyclic group

[题目附件](cyclic%20group.py)

{{< raw >}} \[
    c \equiv m^{e} \mod p \\
    d \equiv e^{-1} \mod \Phi(p )\\
    m \equiv m^{1+k*\Phi(p)} \equiv c^{e*d} \mod p 
\] {{< /raw >}}

```python
print(long_to_bytes(pow(c, gmpy2.invert(e, p - 1), p)))
```


## 🦕 cnss娘的代码Ⅰ

[题目附件](cnss娘的代码Ⅰ.py)

模互素的线性同余方程组，使用 CRT 即可.

```python
print(long_to_bytes(crt(secret,key)))
```


## 🐢 RSA Ⅰ

[题目附件](RSAⅠ.py)

同时知道 `p|mask` `p&mask` ,可以很轻易地按位还原出 p.

```python
mk = (2 ** 512) -1
p = andp | (mk ^^ mask) & orp
q = n//p
phi = (p-1)*(q-1)
d = inverse_mod(e,phi)
flag = long_to_bytes(pow(c,d,n))
print(flag)
```


## 🐲 cnss娘的代码 Ⅱ

[题目附件](cnss娘的代码Ⅱ.py)

离散对数问题，直接求就行.

```python
G = GF(p)
m = discrete_log(G(h),G(g))
print(long_to_bytes(m))
```


## 🐳 cnss娘的代码 Ⅲ

[题目附件](cnss娘的代码Ⅲ.sage)

{{< raw >}} \[
    v = u * A \Rightarrow u = v*A^{-1}
\] {{< /raw >}}

```python
G = GF(p)
u = A.solve_left(v)
flag = b""
for item in u:
    flag += long_to_bytes(int(item))
print(flag)
```


## 🌛 HomoBlock

[题目附件](HomoBlock.py)

```python
def NotHomoFunction(x,iv,key):
    return ((x<<iv)&MASK1)^((x>>iv)|MASK2)^key
```
我们先来分析加密过程, `NotHomoFunction` 在每一轮中实际上换了高 8 位和低 8 位, 然后异或上 `key ^ MASK2`. 那么每两组密文的异或就是
`cipher[i] ^ cipher[i+1] = m[i] ^ m[i+1]` 其中 `m[i]` 中高低 8 位进行了替换. 

在这种加密模式下我们知道第一组明文的值, `m[0] = bytes_to_long(b"cnss{I_a")`. 我们就可以还原出整个明文.

```python
init = b"cnss{I_a"
m = [ 0 for i in range(5)]
m[0] = bytes_to_long(init)
m[0] = ((m[0]<<32)&(0xffffffff00000000)) | ((m[0]>>32)&(0x00000000ffffffff))
for i in range(4):
    m[i+1] = m[i] ^^ cipher[i] ^^ cipher[i+1]
flag = b""
for i in range(5):
    m[i] = ((m[i]<<32)&(0xffffffff00000000)) | ((m[i]>>32)&(0x00000000ffffffff))
    flag += long_to_bytes(m[i])
print(flag)
```

{{< admonition>}}
以下部分是临时更新喵, 暂时没有旁白解释, 请见谅.
{{< /admonition >}}

## 🐠 ezLFSR

[题目附件](ezLFSR.rar)

```python
lenmask = 2 ** 16 -1
seed = 37285
mask = 46359
ifile=open("cipher.enc",'rb')
plaintext=ifile.read()
flag = "cnss{**************************}"
assert len(flag) == 32

seq = ""
for i in range(5):
    seq += "{:08b}".format(plaintext[i]^^ord(flag[i]))

for mask in range(65536):
    state = seed & lenmask
    mask &= lenmask
    for j in range(5 * 8):
        nextstate = (state<<1) & lenmask
        tmp  = state & mask & lenmask
        output = 0
        while tmp != 0:
            output ^^= (tmp & 1)
            tmp >>= 1
        nextstate ^^= output
        state = nextstate
        if output != int(seq[j]):
            break

state = seed & lenmask
mask &= lenmask
flag = ""
for i in range(32):
    m = plaintext[i]
    seq = 0
    for j in range(8):
        nextstate = (state<<1) & lenmask
        tmp  = state & mask & lenmask
        output = 0
        while tmp != 0:
            output ^^= (tmp & 1)
            tmp >>= 1
        nextstate ^^= output
        state = nextstate
        seq = (seq <<1 ) ^^ output
    flag += chr(seq ^^ m)

assert len(flag) == 32
print(flag)      
ifile.close()
```


## 🐍 RSA Ⅱ

[题目附件](RSAⅡ.py)

```python
P = 0
Q = 0
SZ = 512
p_bits =  [None for i in range(SZ)]
q_bits =  [None for i in range(SZ)]
for i in range(SZ):
    if (mask1>>i & 1) == 1:
        p_bits[i] = h1 >> i & 1
    if (mask2>>i & 1) == 1:
        q_bits[i] = h2 >> i & 1

def dfs(p, q, x):    
    if x == SZ:
        if p * q == n:
            global P,Q
            P = p
            Q = q
        return
    lenmask = 2**(x+1) - 1
    _p = [0,1] if p_bits[x] == None else [p_bits[x]]
    _q = [0,1] if q_bits[x] == None else [q_bits[x]]
    for pi in _p:
        for qi in _q:
            next_p = pi<<x | p
            next_q = qi<<x | q
            if next_p * next_q & lenmask == n & lenmask:
                dfs(next_p, next_q, x + 1)

dfs(1, 1, 1)
phi = (P - 1) * (Q - 1)
d = inverse_mod(e, phi)
flag = pow(c, d, n)
print(long_to_bytes(flag))
```


## 🦓 BabyLattice

[题目附件](baby_lattice.py)

```python
n = 4
L = Matrix.zero(n+2)
for i in range(n+2):
    L[i, i] = 1
for i in range(n):
    L[i, 4] = numRound[i]
L[4, 4] = modulus
L[5, 4] = -result
res = L.LLL()[0]%modulus
flag = b""
for it in res:
    flag += long_to_bytes(it)
print(flag)
```


## 🖥️ ezSignature

[题目附件](ezSignature.py)

```python
REMOTE = remote("x.x.x.x", xxx)
# pass proof
# sign
# get p q g y r s1 s2
m = b"I'm Admin.I want flag."
m1 = b'I want to tell you a secret'
m2 = b'Can you find it?'
h = bytes_to_long(sha256(m).digest())
h1 = bytes_to_long(sha256(m1).digest())
h2 = bytes_to_long(sha256(m2).digest())

k = (inverse(s1-s2, q)*(h1-h2))%q
assert pow(g, k, p) % q == r
x = inverse(r, q)*(k*s1-h1)%q
assert pow(g, x, p) == y
# fake sign
s = (inverse(k, q)*(h+x*r))%q
print("[+] fake sign: ", )
print("    r: ", r)
print("    s: ", s)

REMOTE.recvuntil(b'your option:')
REMOTE.sendline(b'2')
REMOTE.recvuntil(b'message:')
REMOTE.sendline(m)
REMOTE.recvuntil(b'r:')
REMOTE.sendline(str(r).encode())
REMOTE.recvuntil(b's:')
REMOTE.sendline(str(s).encode())
mes = REMOTE.recv()
print(mes[mes.find(b"cnss"):-1])
REMOTE.close()
```

## 🦊 StrangeCurve

[题目附件](StrangeCurve.sage)

```python
sys.path.append("./crypto-attacks/attacks/ecc")
from smart_attack import attack
p = 1096126227998177188652856107362412783873814431647
a = 0
b = 5
E = EllipticCurve(GF(p), [a, b])
base_point = E(626099523290649705896889901241128842906228328604,886038875771695334071307095455656761758842526929)
Q = E(240653647745552223089451307742208085297121769374, 1041806436100548540817642210994295951394712587396)
flag = b"cnss{"+long_to_bytes(attack(base_point, Q))+b"}"
print(flag)
```

## 🐮 一🔪一个牛头人

[题目附件](一刀一个牛头人.sage)

```python
qdiv3 = Integers(q)(1/3)
h3 = (Integer(qdiv3)*h) % q
L = Matrix(2*N)
for i in range(N):L[i,i] = q
for i in range(N,2*N): L[i,i] = 1
for i in range(N):
    for j in range(N):
        L[i+N,j] = convolution(h3,x^i,R)[j]
Mreduced = L.LLL()
linehao = 0
for item in Mreduced:
    f = Zx(list(item[N:]))
    try:
        fp = invert_poly_mod_prime(f, R, p)
    except:
        linehao+=1
        continue
    else:
        print(f"Find line = {linehao}")
        break
a = balancedmod(convolution(c, f, R), q, R)
mm = balancedmod(convolution(a, fp, R), p, R)

def decode(poly):
    result = 0
    ll = poly.list()
    for idx, val in enumerate(ll):
        result += (val + p // 2) * (p ** idx)
    return result

print(long_to_bytes(decode(mm)))
```

## 🦄 MidLattice

[题目附件](MidLattice.zip)

```python
sys.path.append("./crypto-attacks/attacks/acd/")
from sda import attack
rbit = 201
with open("output.txt","r") as file:
    sample = file.read()
    file.close()
sample = list(map(int,sample[1:-1].split(',')))
p ,r =  attack(sample, rbit)
flag = 'cnss{'+hashlib.sha256(long_to_bytes(p)).hexdigest()+'}'
print(flag)
```

## ⛏️ 铜匠的世界

[题目附件](铜匠的世界.py)

不会喵w^w, 怎么把 `isqrt` 和 `^^` 两次损失的信息利用起来呢?

---
能力有限只做到了这里，没有题解脚本了, 各位大佬见谅哩. 

最后一题解法找 lvsun 问了一下还是爆破+smallroots, 使用 flatter 加速可以减少爆破时间. 

