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
    cnt = 0
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
        else:
            cnt+=1
    if cnt == 5*8:
        # print(f"[+] mask = {mask}")
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


## 🦓 BabyLattice


## 🖥️ ezSignature



## 🦊 StrangeCurve


## 🐮 一🔪一个牛头人


## 🦄 MidLattice


## ⛏️ 铜匠的世界

不会喵w^w, 怎么把 `isqrt` 和 `^^` 两次损失的信息利用起来呢?

