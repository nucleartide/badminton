pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
c=circfill
l=function(a,b,t)return(1-t)*a+t*b
end
::_::
cls(1)
for i=0,15 do
x=i/16+t()/4
sx,sy,ex,ey=64,90,64+23*cos(x),38+5*sin(x)
for j=0.5,1,0.05 do
c(l(sx,ex,j),l(sy,ey,j),3-abs(0.75-j)*5,7)end
line(ex,ey,sx,sy,15)end
c(64,84,7,7)
rectfill(57,77,71,81,0)
flip()
goto _
