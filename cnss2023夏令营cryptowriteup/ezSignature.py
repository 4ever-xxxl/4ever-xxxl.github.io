from Crypto.Util.number import *
from hashlib import sha256
import socketserver
import signal
import string
from random import *
from secret import flag
from Crypto.PublicKey import DSA

table = string.ascii_letters + string.digits


class DigitalSignatureAlgorithm:
    def __init__(self, key):
        self.p = key.p
        self.q = key.q
        self.g = key.g
        self.y = key.y
        self.x = key.x
        self.k = randint(1, self.q - 1)

    def sign(self, m):
        k = self.k
        h = bytes_to_long(sha256(m).digest())
        r = pow(self.g, k, self.p) % self.q
        s = inverse(k, self.q) * (h + self.x * r) % self.q
        return r, s

    def verify(self, m, signature):
        r, s = signature
        if (not (1 <= r <= self.q - 1)) or (not (1 <= s <= self.q - 1)):
            return False
        z = bytes_to_long(sha256(m).digest())
        w = inverse(s, self.q)
        u1 = (z * w) % self.q
        u2 = (r * w) % self.q
        v = (pow(self.g, u1, self.p) * pow(self.y, u2, self.p)) % self.p % self.q
        return r == v


myDSA = DigitalSignatureAlgorithm(DSA.generate(1024))
MENU = br'''
[1] Sign.
[2] Verify.
[3] Get_public_key.
[4] Exit.
'''


class Task(socketserver.BaseRequestHandler):
    def _recvall(self):
        BUFF_SIZE = 2048
        data = b''
        while True:
            part = self.request.recv(BUFF_SIZE)
            data += part
            if len(part) < BUFF_SIZE:
                break
        return data.strip()

    def send(self, msg, newline=True):
        try:
            if newline:
                msg += b'\n'
            self.request.sendall(msg)
        except:
            pass

    def recv(self, prompt=b'[-] '):
        self.send(prompt, newline=False)
        return self._recvall()

    def proof_of_work(self):
        proof = (''.join([choice(table) for _ in range(12)])).encode()
        sha = sha256(proof).hexdigest().encode()
        self.send(b"[+] sha256(XXXX+" + proof[4:] + b") == " + sha)
        XXXX = self.recv(prompt=b'[+] Plz Tell Me XXXX :')
        if len(XXXX) != 4 or sha256(XXXX + proof[4:]).hexdigest().encode() != sha:
            return False
        return True

    def sign(self):
        m1 = b'I want to tell you a secret'
        m2 = b'Can you find it?'
        signature1 = myDSA.sign(m1)
        signature2 = myDSA.sign(m2)
        self.send(b'Your signature1 is:' + str(signature1).encode())
        self.send(b'Your signature2 is:' + str(signature2).encode())

    def verify(self):
        m = self.recv(b'message:')
        r = int(self.recv(b'r:'))
        s = int(self.recv(b's:'))
        signature = (r, s)
        if m == b"I'm Admin.I want flag.":
            if myDSA.verify(m, signature):
                self.send(b'Hello there.This is what you want.')
                self.send(flag)
            else:
                self.send(b'Who are U?Get out!')
                return False
        else:
            self.send(b'Who are U?Get out!')

    def get_public_key(self):
        self.send(b'p = ' + str(myDSA.p).encode())
        self.send(b'q = ' + str(myDSA.q).encode())
        self.send(b'g = ' + str(myDSA.g).encode())
        self.send(b'y = ' + str(myDSA.y).encode())


    def handle(self):
        signal.alarm(30)
        if not self.proof_of_work():
            self.send(b'You must pass the P0W!!!')
            self.request.close()
        while 1:
            self.send(MENU)
            option = int(self.recv(prompt=b'Give me your option:'))
            if option == 1:
                self.sign()
            elif option == 2:
                self.verify()
                break
            elif option == 3:
                self.get_public_key()
            else:
                break
        self.request.close()


class ThreadedServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass


if __name__ == "__main__":
    HOST, PORT = '0.0.0.0', 10001

    print("HOST:POST " + HOST + ":" + str(PORT))
    server = ThreadedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()
