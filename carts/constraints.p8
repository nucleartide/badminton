pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--
-- game loop.
--

function _init()
  -- enable mouse
  poke(0x5f2d, 1)

  -- make mouse
  mouse = {
    x = 20,
    y = 30,
  }

  -- make arm
  arm = make_arm()
end

local anchor={x=64,y=64}
function _update60()
  -- update anchor pos
  if (btn(0)) anchor.x -= 1
  if (btn(1)) anchor.x += 1
  if (btn(2)) anchor.y -= 1
  if (btn(3)) anchor.y += 1

  -- update mouse
  mouse.x = stat(32)
  mouse.y = stat(33)

  -- reach
  reach_arm(arm)
end

function _draw()
  cls(2)

  -- draw arm lines
  --for i=1,#arm-1 do
   local p1=arm[3]
   local p2=arm[4]
   line(
    p1.x,p1.y,
    p2.x,p2.y,
    7
   )
  --end

  -- draw arm
  for i=1,#arm do
   local p=arm[i]
   circfill(p.x,p.y,2,7)
  end

  -- draw target
  circfill(
   mouse.x,
   mouse.y,
   2,
   11
  )
end

--
-- joint & arm.
--

function make_joint(x,y)
  return {
    x=x,
    y=y,
  }
end

function make_arm()
  local a=make_joint(20, 30) -- socket
  local b=make_joint(30, 30) -- elbow
  local c=make_joint(20, 40) -- wrist
  local d=make_joint(10, 50) -- racket head
  -- limits must be positive
  a.limits={a=0.625,b=0.375}
  b.limits={a=0.3,b=0.925}
  c.limits={a=0.5,b=0.99}
  a.in_range=false
  b.in_range=false
  c.in_range=false
  return {a,b,c,d}
end

--
-- math utils.
--

function dot(a, b)
  return a.x * b.x + a.y * b.y
end

function dist(v1, v2)
  local x = v2.x - v1.x
  local y = v2.y - v1.y
  return sqrt(x*x + y*y)
end

function mag(v)
  return sqrt(v.x*v.x + v.y*v.y)
end

function cross(a,b)
  return {
    x = a.y * b.z - a.z * b.y,
    y = a.z * b.x - a.x * b.z,
    z = a.x * b.y - a.y * b.x,
  }
end

function vector_project(a, b)
  local d = dot(a, b)
  local m = mag(b)
  local s = d/(m*m)
  return {
    x=b.x*s,
    y=b.y*s,
  }
end

-- note: pass in 3d vectors.
function is_same_side_util(v1, v2, comparison_vec)
  local a = cross(v1, comparison_vec)
  local b = cross(v2, comparison_vec)
  return sgn(a.z) == sgn(b.z)
end

--
-- reach.
--

function vec3_print(v)
  print(v.x .. ',' .. v.y .. ',' .. v.z)
end

-- `prev_head` - optional
-- `is_forward_reach` - optional
function reach(head, tail, target, head_tail_len, prev_head)
  local head_tail_len = head_tail_len

  local tail_target_len = dist(tail, target)

  local scale = head_tail_len / tail_target_len

  -- set head
  head.x = target.x
  head.y = target.y

  -- set tail
  tail.x = target.x + (tail.x-target.x)*scale
  tail.y = target.y + (tail.y-target.y)*scale

  -- if no previous joint,
  -- then we don't need to apply angular limits
  if not prev_head then return end

  -- 1. find perpendicular line.
  local x=prev_head.x-head.x
  local y=prev_head.y-head.y
  local perp=cross({x=0,y=0,z=-1},{x=x,y=y,z=0})

  -- 2. determine whether `prev_head` and `tail` lie on same side.
  -- vec3_print({x=tail.x-head.x,y=tail.y-head.y,z=0})
  -- vec3_print({x=prev_head.x-head.x,y=prev_head.y-head.y,z=0})
  -- vec3_print(perp)
  local is_same_side = is_same_side_util(
    {x=tail.x-head.x,y=tail.y-head.y,z=0},
    {x=prev_head.x-head.x,y=prev_head.y-head.y,z=0},
    perp
  )

  -- 3. compute projection vector using `is_same_side`.
  local sign = is_same_side and 1 or -1
  local proj=vector_project(
    {x=tail.x-head.x,y=tail.y-head.y},
    {x=sign*x,y=sign*y}
  )

  -- 4. figure out angle using `atan2`.
  local o
  do
    local is_same_side = is_same_side_util(
      {x=perp.x,y=perp.y,z=0},
      {x=tail.x-head.x,y=tail.y-head.y,z=0},
      {x=x,y=y,z=0}
    )
    local sign=is_same_side and -1 or 1 -- negate for y axis
    o=sign*mag({
      x=(tail.x-head.x)-proj.x,
      y=(tail.y-head.y)-proj.y
    })
  end

  local a=mag(proj)*sign -- use sign from above
  local angle=atan2(a,o)

  -- 6. check if normalized angle is in range.
  local in_range
  if head.limits.a < head.limits.b then
    in_range = true
      and head.limits.a <= angle
      and angle         <= head.limits.b
  else
    in_range = false
      or angle <= head.limits.b
      or head.limits.a <= angle
  end

  -- 7a. if in range, great!
  if in_range then
    return
  end

  -- 7b. else, find the closest angle.
  local start_limit=head.limits.a
  local end_limit=head.limits.b
  local closest=closest_angle(start_limit,end_limit,angle)
  local closest_a = closest == 0 and start_limit or end_limit

  -- 8. add angle between x axis and head->prev_head vector.
  local additional_angle = atan2(x, y)
  local final_angle = closest_a + additional_angle

  -- 9. compute new point of tail.
  tail.x = head.x + head_tail_len * cos(final_angle)
  tail.y = head.y + head_tail_len * sin(final_angle)
end

-- return 0 for a, 1 for b
function closest_angle(a,b,angle)
  assert(a != b)
  local diffa = min(abs(angle-a), abs(angle-a+1))
  local diffb = min(abs(angle-b), abs(angle-b+1))
  if (diffa <= diffb) return 0
  return 1
end

--
-- reach arm.
--

function reach_arm(arm)
  local head
  local tail
  local tar

  -- backward
  head=arm[4]
  tail=arm[3]
  tar=mouse
  reach(head,tail,tar,20)

  head=arm[3]
  tail=arm[2]
  tar=head
  reach(head,tail,tar,15)

  head=arm[2]
  tail=arm[1]
  tar=head
  reach(head,tail,tar,15)

  -- forward
  head=arm[1]
  tail=arm[2]
  tar=anchor
  reach(head,tail,tar,15,{x=128,y=64,z=0})

  head=arm[2]
  tail=arm[3]
  tar=head
  reach(head,tail,tar,15,arm[1])

  head=arm[3]
  tail=arm[4]
  tar=head
  reach(head,tail,tar,20,arm[2])
end
__map__
00000c00c84c12000000000032332800c84c120000000000ceccd7ff00000600c84c120000000000ceccd7ff38b3edff00000000ceccd7ff0000060038b3edff00000000ceccd7ff38b3edff00000000323328000000060038b3edff0000000032332800c84c12000000000032332800000006003c8a0f0000000000ceccd7ff
3c8a0f00000000003233280000000600c475f0ff00000000ceccd7ffc475f0ff00000000323328000000060000000000000000002e5cdcff0000000000000000ba1ef4ff000006000000eeff000000002e5cdcff00001200000000002e5cdcff000006000000eeff00000000d2a323000000120000000000d2a3230000000600
ce4ceeff0000000046e10b0032b311000000000046e10b0000000600ce4ceeff00000000ba1ef4ff32b3110000000000ba1ef4ff000006000000000000000000d2a32300000000000000000046e10b000000060000002d00ce4ceeff9c1908000000000032b311009c1908000000000000000500ce4ceeff3833070000000000
32b31100383307000000000000000500ce4ceeffd44c06000000000032b31100d44c06000000000000000500ce4ceeff706605000000000032b311007066050000000000000005003233efff32b30800000000003233efff6466050000000000000005009619f0ff32b30800000000009619f0ff646605000000000000000500
fafff0ff32b3080000000000fafff0ff6466050000000000000005005ee6f1ff32b30800000000005ee6f1ff646605000000000000000500c2ccf2ff32b3080000000000c2ccf2ff64660500000000000000050026b3f3ff32b308000000000026b3f3ff6466050000000000000005008a99f4ff32b30800000000008a99f4ff
646605000000000000000500ee7ff5ff32b3080000000000ee7ff5ff6466050000000000000005005266f6ff32b30800000000005266f6ff646605000000000000000500b64cf7ff32b3080000000000b64cf7ff6466050000000000000005001a33f8ff32b30800000000001a33f8ff6466050000000000000005007e19f9ff
32b30800000000007e19f9ff646605000000000000000500e2fff9ff32b3080000000000e2fff9ff64660500000000000000050046e6faff32b308000000000046e6faff646605000000000000000500aaccfbff32b3080000000000aaccfbff6466050000000000000005000eb3fcff32b30800000000000eb3fcff64660500
00000000000005007299fdff32b30800000000007299fdff646605000000000000000500d67ffeff32b3080000000000d67ffeff6466050000000000000005003a66ffff32b30800000000003a66ffff6466050000000000000005009e4c000032b30800000000009e4c00006466050000000000000005000233010032b30800
00000000023301006466050000000000000005006619020032b308000000000066190200646605000000000000000500caff020032b3080000000000caff02006466050000000000000005002ee6030032b30800000000002ee6030064660500000000000000050092cc040032b308000000000092cc04006466050000000000
00000500f6b2050032b3080000000000f6b205006466050000000000000005005a99060032b30800000000005a990600646605000000000000000500be7f070032b3080000000000be7f07006466050000000000000005002266080032b308000000000022660800646605000000000000000500864c090032b3080000000000
864c0900646605000000000000000500ea320a0032b3080000000000ea320a006466050000000000000005004e190b0032b30800000000004e190b00646605000000000000000500b2ff0b0032b3080000000000b2ff0b0064660500000000000000050016e60c0032b308000000000016e60c00646605000000000000000500
7acc0d0032b30800000000007acc0d00646605000000000000000500deb20e0032b3080000000000deb20e0064660500000000000000050042990f0032b308000000000042990f00646605000000000000000500a67f100032b3080000000000a67f1000646605000000000000000500ce4ceeff000009000000000032b31100
000009000000000000000700ce4ceeff0000000000000000ce4ceeff00000900000000000000080032b31100000000000000000032b31100000009000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
