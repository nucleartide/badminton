pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- a hat for a typescript witch
-- by @nucleartide
cls()
circfill(64,94,10,15)
::_::
--for i=0,127 do
--for j=0,127 do

h=5/sqrt(26)
r=1/sqrt(26)
x,y,z=0,0.0,-1.75
i,j=rnd(128),rnd(128)
u=i/128-.5
v=-(j/128-.25)
--v=-(j/128)
w=sqrt(1-u*u-v*v)
for k=1,20 do
  if z>4 or y<-1 then break end

  -- -sphere
  -- s2=sqrt(x*x+y*y+z*z)-1

  -- torus
  -- q2=sqrt(x*x+z*z)-1
  -- s2=sqrt(q2*q2+y*y)-0.5

  -- cone
  q2=sqrt(x*x+z*z)
  s=h*q2+r*y

  dx=sqrt(x*x+z*z)-0.4
  dy=abs(y+0.9)-0.005
  l=sqrt(max(dx,0)^2+max(dy,0)^2)
  s2=min(max(dx,dy),0)+l

  --q=sqrt(x*x+z*z)
  --s=q-r

  --if min(abs(s),abs(s2)) < 0.08 then
  m=min(s2, s)
  --m=abs(s)
  if m < 0.08 and m>0 then
    a=t()/64+atan2(z,x)
            c=flr(9+sin(a*3))
            if c==9 then c=1
            elseif c==8 then
              if (a%1)>0.66 then
                c=13
              else
                c=12
              end

            end
            pset(i,j,c)

  end
  x+=u*m
  y+=v*m
  z+=w*m
end

--end
--end
--flip()
goto _
