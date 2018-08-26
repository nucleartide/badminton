pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
local map_addr = 0x2000
local written  = 0

local function vec3(x, y, z)
  return {
    x = x or 0,
    y = y or 0,
    z = z or 0,
  }
end

local function vec3_print(v)
  print(v.x .. ', ' .. v.y .. ', ' .. v.z)
end

local
  write_num, -- write number with range [-32768.0, 32767.9999].
  write_vec3
do
  write_num = function(n)
    poke4(map_addr+written, n)
    written = written+4
  end

  write_vec3 = function(v)
    write_num(v.x)
    write_num(v.y)
    write_num(v.z)
  end
end

local
  read_num, -- read number with range [-32768.0, 32767.9999].
  read_vec3
do
  local offset = 0

  read_num = function()
    local n = peek4(map_addr+offset)
    offset = offset+4
    return n
  end

  read_vec3 = function()
    return vec3(read_num(), read_num(), read_num())
  end
end

local s = 6
local points = {
  vec3((3.05)*s,  0, (6.7)*s),
  vec3((3.05)*s,  0, (-6.7)*s),
  vec3((-3.05)*s, 0, (-6.7)*s),
  vec3((-3.05)*s, 0, (6.7)*s),

  -- 5
  vec3((2.59)*s, 0, (-6.7)*s),
  vec3((2.59)*s, 0, ( 6.7)*s),

  -- 7
  vec3((-2.59)*s, 0, (-6.7)*s),
  vec3((-2.59)*s, 0, ( 6.7)*s),

  -- 9
  vec3((-3.05)*s, 0, 0),
  vec3(( 3.05)*s, 0, 0),

  -- 11
  vec3(0, 0, (-5.94)*s),
  vec3(0, 0, -1.98*s),

  -- 13
  vec3((-3.0)*s, 0, (-5.94)*s),
  vec3(( 3.0)*s, 0, (-5.94)*s),

  -- 15
  vec3((-3.0)*s, 0, (5.94)*s),
  vec3(( 3.0)*s, 0, (5.94)*s),

  -- 17
  vec3((-2.95)*s, 0, (1.98)*s),
  vec3(( 2.95)*s, 0, (1.98)*s),

  -- 19
  vec3((-2.95)*s, 0, (-1.98)*s),
  vec3(( 2.95)*s, 0, (-1.98)*s),

  -- 21
  vec3(0, 0, (5.94)*s),
  vec3(0, 0, 1.98*s),
}
local colors_light_gray = 6
local lines = {
  {points[1], points[2], colors_light_gray},
  {points[2], points[3], colors_light_gray},
  {points[3], points[4], colors_light_gray},
  {points[4], points[1], colors_light_gray},
  {points[5], points[6], colors_light_gray},
  {points[7], points[8], colors_light_gray},
  {points[11], points[12], colors_light_gray},
  {points[13], points[14], colors_light_gray},
  {points[15], points[16], colors_light_gray},
  {points[17], points[18], colors_light_gray},
  {points[19], points[20], colors_light_gray},
  {points[21], points[22], colors_light_gray},
}

local net_points = {
  vec3(-2.95*s, 1.5*s, 0),
  vec3( 2.95*s, 1.5*s, 0),

  vec3(-2.95*s, 0, 0),
  vec3(-2.95*s, 1.5*s, 0),

  vec3(2.95*s, 0, 0),
  vec3(2.95*s, 1.5*s, 0),
}

local net_lines = {
}

for i=1,4 do
  local y = 1.5-i*0.15
  add(net_lines, {
    vec3(-2.95*s, y*s, 0),
    vec3(2.95*s, y*s, 0),
    5
  })
end

-- points closer to the center need slight mods (toward zero)
-- for their x coord, because of the discrepancy between
-- line drawing and projected points

for i=1,38 do
  local x = -2.95+i*0.15 -- last x is 2.75 - close enough
  add(net_lines, {
    vec3(x*s, 1.45*s, 0),
    vec3(x*s, 0.9*s, 0), -- same as lower bound of horiz net lines
    5,
  })
end

-- white line on top
add(net_lines, {net_points[1], net_points[2], 7})

-- red side lines
add(net_lines, {net_points[3], net_points[4], 8})
add(net_lines, {net_points[5], net_points[6], 8})

write_num(#lines)
for l in all(lines) do
  write_vec3(l[1])
  write_vec3(l[2])
  write_num(l[3])
end

write_num(#net_lines)
for l in all(net_lines) do
  write_vec3(l[1])
  write_vec3(l[2])
  write_num(l[3])
end

-- read data and print as a sanity check.
--print(read_num(#lines))
for i=1,#lines do
 read_vec3()
 read_vec3()
 read_num()
end

--print(read_num(#net_lines))
for i=1,#net_lines do
  vec3_print(read_vec3())
  vec3_print(read_vec3())
  --print(read_num())
end

--[[

  todo:

  [x] write line count
  [x] for each line, write vec3 and color

--]]

if written > 4096 then
  -- not enough map data, need to optimize.
  assert(false)
end

cstore(map_addr, map_addr, written, 'badminton-data.p8')
