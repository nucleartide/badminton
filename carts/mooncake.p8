pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
::_::
cls(7)p=240
q=t()*30
for c=0,4 do
for i=0,p-1 do
r=21+3*abs(sin(i/p*6))-2
pset(64+r*cos((i+q)/p),64+c*2+r*sin((i+q)/p)/1.5,15)end
end
for c=0,9 do
for i=0,p-1 do
r=c*2+3*abs(sin((i)/p*6))pset(64+r*cos((i+q)/p),64+(c-10)+r*sin((i+q)/p)/1.5,c<8 and 4 or 9)end
end
flip()goto _
