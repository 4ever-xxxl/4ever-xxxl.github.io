from Crypto.Util.number import *
from secret import flag

m = bytes_to_long(flag)
p = getPrime(512)
q = getPrime(512)
n = p*q


e=65537
c = pow(m,e,n)
mask = getPrime(512)
print(f'c = {c}')
print(f'n = {n}')
print(f'mask = {mask}')
print(p|mask)
print(p&mask)

#c = 64949799997326584007544788513993497249594769744995858720976935000014197232306799968807213667255871030075230919683627404813038995304033226711042639925325815395252041199650244620814678407788637241064396318107929964286966081900052163098825412222835465966640369222321472659135622216530966800717417560715221275591
#n = 106750680418525866311589462967145265327203310954735134383588573660691518247034803380198999333962213971657327515092895034635965957228036264848532931376595751503164297061094511187060069380048933807326213369464059701069965785612620370291933800122445966488267918733547599024267999872488061941892122230382138042783
#mask = 12270330408774238331968219216635392599519489634111741706590917012819298856158311310855782884352875794146685141255943386189197362902992928716839082520848927
#13112112110892990771168306272793201342028151601627796725313855804865001339738164412798270175076178951452110894792943424133718769511979832250960465757056799
#11731832079629748669705816329667815638461774924918417348984676937048335348013101619038697983623814812736529127108466295988845879378764866277739393693264401