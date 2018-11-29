pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- lua library imports
local meter = 6

local second = 60

local win_score = 1

local zero_vec = {x = 0,y = 0,z = 0}

col={}
col.black=0
col.dark_blue=1
col.dark_purple=2
col.dark_green=3
col.brown=4
col.dark_gray=5
col.light_gray=6
col.white=7
col.red=8
col.orange=9
col.yellow=10
col.green=11
col.blue=12
col.indigo=13
col.pink=14
col.peach=15
palette={}
palette.draw=0
palette.screen=1
button={}
button.left=0
button.right=1
button.up=2
button.down=3
button.z=4
button.x=5
state={}
state.pre_serve=0
state.serving=1
state.rally=2
state.post_rally=3
function vec3(x,y,z)
    return {x = x or 0,y = y or 0,z = z or 0}
end
function vec3_add(out,a,b)
    local ax = a.x

    local ay = a.y

    local az = a.z

    local bx = b.x

    local by = b.y

    local bz = b.z

    out.x = (ax+bx)
    out.y = (ay+by)
    out.z = (az+bz)
end
function vec3_sub(out,a,b)
    local ax = a.x

    local ay = a.y

    local az = a.z

    local bx = b.x

    local by = b.y

    local bz = b.z

    out.x = (ax-bx)
    out.y = (ay-by)
    out.z = (az-bz)
end
function vec3_mul(out,a,b)
    out.x = (a.x*b.x)
    out.y = (a.y*b.y)
    out.z = (a.z*b.z)
end
function vec3_print(v)
    print(v.x .. ", " .. v.y .. ", " .. v.z)
end
function vec3_printh(v)
    printh(v.x .. ", " .. v.y .. ", " .. v.z,"test.log")
end
function vec3_dot(a,b)
    return ((a.x*b.x)+(a.y*b.y))+(a.z*b.z)
end
function vec3_cross(out,a,b)
    local ax = a.x

    local ay = a.y

    local az = a.z

    local bx = b.x

    local by = b.y

    local bz = b.z

    out.x = ((ay*bz)-(az*by))
    out.y = ((az*bx)-(ax*bz))
    out.z = ((ax*by)-(ay*bx))
end
function vec3_scale(v,c)
    v.x = (v.x*c)
    v.y = (v.y*c)
    v.z = (v.z*c)
end
function vec3_magnitude(v)
    if ((v.x>104) or (v.y>104)) or (v.z>104) then
        local m = max(max(v.x,v.y),v.z)

        local x = v.x/m
local y = v.y/m
local z = v.z/m

        return sqrt(((x^2)+(y^2))+(z^2))*m
    end
    return sqrt(((v.x^2)+(v.y^2))+(v.z^2))
end
do
local spare = vec3()

vec3_dist = function(a,b)
    vec3_sub(spare,a,b)
    return vec3_magnitude(spare)
end

end
function vec3_normalize(v)
    local m = vec3_magnitude(v)

    if m==0 then
        return
    end
    v.x = (v.x/m)
    v.y = (v.y/m)
    v.z = (v.z/m)
end
function vec3_lerp(out,a,b,t)
    local ax = a.x
local ay = a.y
local az = a.z

    local bx = b.x
local by = b.y
local bz = b.z

    out.x = lerp(ax,bx,t)
    out.y = lerp(ay,by,t)
    out.z = lerp(az,bz,t)
end
local vec3_mul_mat3 = nil

do
local spare = vec3()

vec3_mul_mat3 = function(out,v,m)
    spare.x = v.x
    spare.y = v.y
    spare.z = v.z
    out.x = vec3_dot(spare,m[0+1])
    out.y = vec3_dot(spare,m[1+1])
    out.z = vec3_dot(spare,m[2+1])
end

end
function assert_vec3_equal(a,b)
    assert(a.x==b.x)
    assert(a.y==b.y)
    assert(a.z==b.z)
end
function vec3_zero(v)
    v.x = 0
    v.y = 0
    v.z = 0
end
function vec3_assign(a,b)
    a.x = b.x
    a.y = b.y
    a.z = b.z
end
function mat3()
    return {vec3(),vec3(),vec3()}
end
function mat3_rotate_x(m,a)
    m[0+1].x = 1
    m[0+1].y = 0
    m[0+1].z = 0
    m[1+1].x = 0
    m[1+1].y = cos(a)
    m[1+1].z = sin(a)
    m[2+1].x = 0
    m[2+1].y = -sin(a)
    m[2+1].z = cos(a)
end
function mat3_rotate_y(m,a)
    m[0+1].x = cos(a)
    m[0+1].y = 0
    m[0+1].z = -sin(a)
    m[1+1].x = 0
    m[1+1].y = 1
    m[1+1].z = 0
    m[2+1].x = sin(a)
    m[2+1].y = 0
    m[2+1].z = cos(a)
end
function round(n)
    return flr(n+0.5)
end
function lerp(a,b,t)
    return ((1-t)*a)+(t*b)
end
function clockwise(points)
    local sum = 0

    local i = 0
    while(i<#points) do
        do
            local point = points[i+1]

            local next_point = points[(i+1)%#points+1]

            sum = (sum+((((next_point.x-point.x)/10)*(next_point.y+point.y))/10))
        end
        ::__continue0::
        i = (i+1)
    end
    return sum<=0
end
local read_num = nil

do
local map_addr = 8192

local offset = 0

read_num = function()
    local n = peek4(map_addr+offset)

    offset = (offset+4)
    return n
end

end
function read_vec3()
    return vec3(read_num(),read_num(),read_num())
end
function insert_into(order,pos,a)
    local i = 0
    while(i<#order) do
        do
            local current = order[i+1]

            if pos.z<current[0+1].z then
                local j = #order-1
                while(j>=i) do
                    do
                        order[j+1+1] = order[j+1]
                    end
                    ::__continue2::
                    j = (j-1)
                end
                order[i+1] = {pos,a}
                return
            end
        end
        ::__continue1::
        i = (i+1)
    end
    add(order,{pos,a})
end
function insert_into2(order,pos,a)
    local i = 0
    while(i<#order) do
        do
            local current = order[i+1]

            if pos.z<current[0+1].z then
                local j = #order-1
                while(j>=i) do
                    do
                        order[j+1+1] = order[j+1]
                    end
                    ::__continue4::
                    j = (j-1)
                end
                order[i+1] = {pos,a}
                return
            end
        end
        ::__continue3::
        i = (i+1)
    end
    add(order,{pos,a})
end
local reach_spare = vec3()

local reach_spare2 = vec3()

function reach(head,tail,target,head_tail_len,constrain)
    vec3_sub(reach_spare,tail,target)
    local stretched_len = vec3_magnitude(reach_spare)

    if stretched_len==0 then
        return
    end
    if constrain then
        local len = vec3_dist(head,tail)

        head_tail_len = min(head_tail_len,len)
        head_tail_len = max(head_tail_len,0.1*meter)
    end
    local scale = head_tail_len/stretched_len

    vec3_assign(head,target)
    vec3_assign(tail,target)
    vec3_scale(reach_spare,scale)
    vec3_add(tail,tail,reach_spare)
end
local actors = nil

local actors_obj = nil

function _init()
    local court_lines = read_lines()

    local net_lines = read_lines()

    local c = cam()

    c.dist = (12*meter)
    c.fov = (34*meter)
    c.x_angle = -0.05
    c.pos.y = (-0.5*meter)
    local n = net(net_lines,c)

    local crt = court(court_lines,c)

    local b = ball(c,n)

    b.pos.x = (1.5*meter)
    b.pos.y = (1.5*meter)
    b.pos.z = (3*meter)
    b.vel.y = (7*meter)
    local g = game(crt,b)

    local player_user = player(c,-0.5*meter,0,5*meter,player_keyboard_input,-1,g,true,player_side.left)

    actors = {g,c,n,crt,player_user,b}
    actors_obj = {camera = c,net = n,court = crt,game = g,player = player_user,ball = b}
end
function _update60()
    local i = 0
    while(i<#actors) do
        do
            local a = actors[i+1]

            a.update(a)
        end
        ::__continue5::
        i = (i+1)
    end
end
function _draw()
    cls(col.dark_purple)
    local order = {}

    insert_into(order,zero_vec,actors_obj.net)
    insert_into(order,(actors_obj.player).pos,actors_obj.player)
    insert_into(order,(actors_obj.ball).pos,actors_obj.ball)
    local court = actors_obj.court

    court.draw(court)
    local i = 0
    while(i<#order) do
        do
            local a = order[i+1][1+1]

            a.draw(a)
        end
        ::__continue6::
        i = (i+1)
    end
    local game = actors_obj.game

    game.draw(game)
end
function read_lines()
    local count = read_num()

    local lines = {}

    local i = 0
    while(i<count) do
        do
            add(lines,{start_vec = read_vec3(),end_vec = read_vec3(),col = read_num(),start_screen = vec3(),end_screen = vec3()})
        end
        ::__continue7::
        i = (i+1)
    end
    return lines
end
function line_draw(l,c)
    cam_project(c,l.start_screen,l.start_vec)
    cam_project(c,l.end_screen,l.end_vec)
    line(round(l.start_screen.x),round(l.start_screen.y),round(l.end_screen.x),round(l.end_screen.y),l.col)
end
function polygon(col,cam,points)
    local points_screen = {}

    local i = 0
    while(i<#points) do
        do
            add(points_screen,vec3())
        end
        ::__continue8::
        i = (i+1)
    end
    return {points_world = points,points_screen = points_screen,col = col,cam = cam}
end
function polygon_update(p)
    local i = 0
    while(i<#p.points_world) do
        do
            cam_project(p.cam,p.points_screen[i+1],p.points_world[i+1])
        end
        ::__continue9::
        i = (i+1)
    end
end
function polygon_edge(v1,v2,xl,xr,is_clockwise)
    local x1 = v1.x

    local x2 = v2.x

    local fy1 = flr(v1.y)

    local fy2 = flr(v2.y)

    local t = (is_clockwise and xr) or xl

    if fy1==fy2 then
        if fy1<0 then
            return 0,0
        end
        if fy1>127 then
            return 127,127
        end
        local xmin = max(min(x1,x2),0)

        local xmax = min(max(x1,x2),127)

        xl[fy1] = (((not xl[fy1]) and xmin) or min(xl[fy1],xmin))
        xr[fy1] = (((not xr[fy1]) and xmax) or max(xr[fy1],xmax))
        return fy1,fy1
    end
    if fy1>fy2 then
        local _ = nil

        _ = x1
        x1 = x2
        x2 = _
        _ = fy1
        fy1 = fy2
        fy2 = _
        t = (((t==xl) and xr) or xl)
    end
    local ys = max(fy1,0)

    local ye = min(fy2,127)

    local m = (x2-x1)/(fy2-fy1)

    local y = ys
    while(y<=ye) do
        do
            t[y] = ((m*(y-fy1))+x1)
        end
        ::__continue10::
        y = (y+1)
    end
    return ys,ye
end
function polygon_draw(p)
    local points = p.points_screen

    local xl = {}
local xr = {}

    local ymin = 32767
local ymax = -32768

    local is_clockwise = clockwise(points)

    local i = 0
    while(i<#points) do
        do
            local point = points[i+1]

            local next_point = points[(i+1)%#points+1]

            local ys,ye=polygon_edge(point,next_point,xl,xr,is_clockwise)

            ymin = min(ys,ymin)
            ymax = max(ye,ymax)
        end
        ::__continue11::
        i = (i+1)
    end
    local y = ymin
    while(y<=ymax) do
        do
            if xl[y] and xr[y] then
                rectfill(round(xl[y]),y,round(xr[y]),y,p.col)
            else
                print(y,0,0,7)
                assert(false)
            end
        end
        ::__continue12::
        y = (y+1)
    end
end
function cam()
    return {pos = vec3(),x_angle = 0,mx = mat3(),y_angle = 0,my = mat3(),dist = 7*10,fov = 150,update = cam_update,draw = cam_draw}
end
function cam_update(_c)
end
function cam_draw(_c)
end
function cam_project(c,out,v)
    vec3_sub(out,v,c.pos)
    mat3_rotate_y(c.my,-c.y_angle)
    vec3_mul_mat3(out,out,c.my)
    mat3_rotate_x(c.mx,-c.x_angle)
    vec3_mul_mat3(out,out,c.mx)
    out.z = (out.z+c.fov)
    local perspective = out.z/c.dist

    out.x = (perspective*out.x)
    out.y = (perspective*out.y)
    out.x = (out.x+64)
    out.y = (-out.y+64)
end
function game(c,b)
    return {update = game_update,draw = game_draw,court = c,ball = b,post_rally_timer = 0,left_side_score = 0,right_side_score = 1,state = state.pre_serve,next_state = state.pre_serve,mouse_x = 0,mouse_y = 0}
end
function game_update(g)
    g.state = g.next_state
    g.mouse_x = stat(32)
    g.mouse_y = stat(33)
end
function game_draw(g)
    local str = g.left_side_score .. " - " .. g.right_side_score

    print(str,64-(#str*2),3,col.white)
end
player_side={}
player_side.left=0
player_side.right=1
player_stance={}
player_stance.forehand=0
player_stance.backhand=1
swing_state={}
swing_state.idle=0
swing_state.winding=1
swing_state.swing=2
function player(c,x,y,z,input_method,player_dir,game,is_initial_server,player_side)
    local points = {vec3(),vec3(),vec3(),vec3()}

    local more_points = {vec3(),vec3(),vec3(),vec3()}

    local p = {pos = vec3(x,y,z),vel = vec3(),vel60 = vec3(),acc = vec3(),desired_speed = 6.5*meter,desired_speed_lerp_factor = 0.5,screen_pos = vec3(),cam = c,input_method = input_method,player_dir = player_dir,game = game,update = player_update,draw = player_draw,player_side = player_side,player_stance = player_stance.forehand,swing_state = swing_state.idle,arm_points = points,arm_screen_points = more_points,target = vec3(),swing_frames = 0,ball_hit = false}

    if is_initial_server then
        game.server = p
    end
    return p
end
function player_move(p)
    vec3_zero(p.acc)
    p.input_method(p)
    if p.acc.x>0 then
        p.player_stance = player_stance.forehand
    end
    if p.acc.x<0 then
        p.player_stance = player_stance.backhand
    end
    vec3_normalize(p.acc)
    vec3_scale(p.acc,p.desired_speed)
    vec3_lerp(p.vel,p.vel,p.acc,p.desired_speed_lerp_factor)
    vec3_assign(p.vel60,p.vel)
    vec3_scale(p.vel60,1/60)
    vec3_add(p.pos,p.pos,p.vel60)
    if p.game.state==state.pre_serve then
        local player_score,opponent_score=get_player_score(p)

        if p.game.server==p then
            if (player_score%2)==0 then
                player_bounds_check(p,p.game.court.singles_even_bounds)
            else
                player_bounds_check(p,p.game.court.singles_odd_bounds)
            end
        else
            if (opponent_score%2)==0 then
                player_bounds_check(p,p.game.court.singles_odd_bounds)
            else
                player_bounds_check(p,p.game.court.singles_even_bounds)
            end
        end
    end
    cam_project(p.cam,p.screen_pos,p.pos)
end
local chest_spare = vec3()

local target_spare = vec3()

local arm_points_spare = vec3()

local arm_socket_offset = vec3(0.1722*meter,0.9227*meter,-0.1627*meter)

local wrist_offset = vec3(0.5525*meter,0.7729*meter,-0.4026*meter)

local racket_head_offset = vec3(0.25*meter,0.75*meter,-1*meter)

local chest_offset = vec3(0,1*meter,0)

local idle_target_offset = vec3(1.15*meter,1*meter,0)

function player_move_arm(p)
    local ball = p.game.ball.pos

    local chest = p.arm_points[0+1]

    local arm_socket = p.arm_points[1+1]

    local wrist = p.arm_points[2+1]

    local racket_head = p.arm_points[3+1]

    local chest_to_arm_socket = 0.25*meter

    local arm_socket_to_wrist = 0.75*meter

    local wrist_to_racket_head = 0.67*meter

    vec3_add(chest_spare,p.pos,chest_offset)
    local dist_to_ball = vec3_dist(ball,chest_spare)/meter

    local near_ball = dist_to_ball<(0.5*meter)

    local min_swing_frames = -50

    local max_swing_frames = 40

    local idle_speed = 5

    local winding_speed = 5

    local swing_speed = -20

    local dist_per_frame = 0.06*meter

    if (p.swing_state==swing_state.idle) and btn(button.x) then
        p.swing_state = swing_state.winding
    end
    if (p.swing_state==swing_state.winding) and (not btn(button.x)) then
        p.swing_state = swing_state.swing
    end
    if (p.swing_state==swing_state.swing) and (p.swing_frames==min_swing_frames) then
        p.swing_state = swing_state.idle
    end
    if p.swing_state==swing_state.idle then
        p.swing_frames = min(p.swing_frames+idle_speed,0)
    end
    if p.swing_state==swing_state.winding then
        p.swing_frames = min(p.swing_frames+winding_speed,max_swing_frames)
    end
    if p.swing_state==swing_state.swing then
        p.swing_frames = max(p.swing_frames+swing_speed,min_swing_frames)
    end
    if near_ball or ((p.swing_state~=swing_state.idle) or (p.swing_frames~=0)) then
        if near_ball then
            vec3_assign(target_spare,ball)
            vec3_sub(target_spare,target_spare,p.pos)
        else
            vec3_assign(target_spare,idle_target_offset)
        end
        target_spare.z = (target_spare.z+((-p.player_dir*dist_per_frame)*p.swing_frames))
        vec3_lerp(target_spare,racket_head,target_spare,0.2)
        reach(racket_head,wrist,target_spare,wrist_to_racket_head)
        reach(wrist,arm_socket,wrist,arm_socket_to_wrist,true)
        reach(arm_socket,chest,arm_socket,chest_to_arm_socket)
        reach(chest,arm_socket,chest_offset,chest_to_arm_socket)
        reach(arm_socket,wrist,arm_socket,arm_socket_to_wrist,true)
        reach(wrist,racket_head,wrist,wrist_to_racket_head)
        vec3_add(chest_spare,p.pos,racket_head)
        local ball_hit = vec3_dist(chest_spare,ball)<(0.5*meter)

        if ball_hit and (p.swing_state==swing_state.swing) then
            p.game.ball.vel.z = ((p.player_dir*30)*meter)
        end
    else
        vec3_lerp(arm_socket,arm_socket,arm_socket_offset,0.2)
        vec3_lerp(wrist,wrist,wrist_offset,0.2)
        vec3_lerp(racket_head,racket_head,racket_head_offset,0.2)
    end
    local len = #p.arm_points

    local i = 0
    while(i<len) do
        do
            vec3_add(arm_points_spare,p.pos,p.arm_points[i+1])
            cam_project(p.cam,p.arm_screen_points[i+1],arm_points_spare)
        end
        ::__continue13::
        i = (i+1)
    end
end
function player_keyboard_input(p)
    if btn(button.left) then
        p.acc.x = (p.acc.x-p.desired_speed)
    end
    if btn(button.right) then
        p.acc.x = (p.acc.x+p.desired_speed)
    end
    if btn(button.up) then
        p.acc.z = (p.acc.z-p.desired_speed)
    end
    if btn(button.down) then
        p.acc.z = (p.acc.z+p.desired_speed)
    end
end
function get_player_score(p)
    local side = p.player_side

    local player_score = nil

    local opponent_score = nil

    if side==player_side.left then
        player_score = p.game.left_side_score
        opponent_score = p.game.right_side_score
    else
        player_score = p.game.right_side_score
        opponent_score = p.game.left_side_score
    end
    return player_score,opponent_score
end
function player_ai(p)
    vec3_zero(p.acc)
end
function player_bounds_check(p,bounds)
    local upper_left_bound = bounds[0+1]

    local lower_right_bound = bounds[1+1]

    if p.pos.x<upper_left_bound.x then
        p.pos.x = upper_left_bound.x
    end
    if p.pos.x>lower_right_bound.x then
        p.pos.x = lower_right_bound.x
    end
    if (p.player_dir==-1) and (p.pos.z<upper_left_bound.z) then
        p.pos.z = upper_left_bound.z
    end
    if (p.player_dir==-1) and (p.pos.z>lower_right_bound.z) then
        p.pos.z = lower_right_bound.z
    end
    if (p.player_dir==1) and (p.pos.z>-upper_left_bound.z) then
        p.pos.z = -upper_left_bound.z
    end
    if (p.player_dir==1) and (p.pos.z<-lower_right_bound.z) then
        p.pos.z = -lower_right_bound.z
    end
end
function player_move_ball(p)
    p.game.ball.is_kinematic = true
    vec3_assign(p.game.ball.pos,p.pos)
    p.game.ball.pos.y = (p.game.ball.pos.y+(1*meter))
    if p.player_stance==player_stance.forehand then
        p.game.ball.pos.x = (p.game.ball.pos.x+(0.5*meter))
    end
    if p.player_stance==player_stance.backhand then
        p.game.ball.pos.x = (p.game.ball.pos.x-(0.5*meter))
    end
    p.game.ball.pos.z = (p.game.ball.pos.z+((p.player_dir*0.1)*meter))
end
function player_pre_serve(p)
    player_move(p)
    player_move_arm(p)
end
function player_update(p)
    if p.game.state==state.pre_serve then
        player_pre_serve(p)
        return
    end
    if p.game.state==state.serving then
        return
    end
    if p.game.state==state.rally then
        return
    end
    if p.game.state==state.post_rally then
        return
    end
    return
end
function player_draw(p)
    local width = 10

    local height = 25

    local screen = vec3()

    local target = vec3()

    local chest = p.arm_screen_points[0+1]

    local socket = p.arm_screen_points[1+1]

    local hand = p.arm_screen_points[2+1]

    local racket_head = p.arm_screen_points[3+1]

    local orderarray = {}

    insert_into2(orderarray,chest,function()
        circfill(round(p.screen_pos.x),round(p.screen_pos.y),3,col.dark_blue)
        rectfill(round(p.screen_pos.x-(width/2)),round(p.screen_pos.y-height),round(p.screen_pos.x+(width/2)),round(p.screen_pos.y),col.orange)
    end
)
    insert_into2(orderarray,socket,function()
        line(socket.x,socket.y,hand.x,hand.y,col.peach)
    end
)
    insert_into2(orderarray,hand,function()
        circfill(hand.x,hand.y,1,col.peach)
        line(hand.x,hand.y,racket_head.x,racket_head.y,col.red)
    end
)
    insert_into2(orderarray,racket_head,function()
        vec3_add(target,p.pos,chest_offset)
        vec3_add(target,target,p.arm_points[3+1])
        target.y = 0
        cam_project(p.cam,screen,target)
        circfill(screen.x,screen.y,2,col.dark_blue)
        circfill(racket_head.x,racket_head.y,3,col.white)
    end
)
    local i = 0
    while(i<#orderarray) do
        do
            orderarray[i+1][1+1]()
        end
        ::__continue14::
        i = (i+1)
    end
end
function ball(c,n)
    return {pos = vec3(0,3*meter,5*meter),shadow_pos = vec3(),vel = vec3(0,1*meter,0),acc = vec3(0,-10*meter,0),screen_pos = vec3(),screen_shadow_pos = vec3(),cam = c,is_kinematic = false,net = n,update = ball_update,draw = ball_draw,spare = vec3(),next_pos = vec3()}
end
function ball_update(b)
    if (not b.is_kinematic) and (b.pos.y>0) then
        vec3_assign(b.spare,b.acc)
        vec3_scale(b.spare,1/60)
        vec3_add(b.vel,b.vel,b.spare)
        vec3_assign(b.spare,b.vel)
        vec3_scale(b.spare,1/60)
        vec3_zero(b.next_pos)
        vec3_add(b.next_pos,b.pos,b.spare)
        local intersects,intersection=net_collides_with(b.net,b.pos,b.next_pos)

        if intersects and intersection then
            b.pos.x = intersection.x
            b.pos.y = intersection.y
            if b.pos.z>0 then
                b.pos.z = 1
            else
                if b.pos.z<0 then
                    b.pos.z = -1
                else
                    assert(false)
                end
            end
            b.vel.z = -b.vel.z
            vec3_scale(b.vel,0.1)
        else
            vec3_add(b.pos,b.pos,b.spare)
        end
    end
    if b.pos.y<0 then
        b.pos.y = 0
    end
    cam_project(b.cam,b.screen_pos,b.pos)
    vec3_assign(b.shadow_pos,b.pos)
    b.shadow_pos.y = 0
    cam_project(b.cam,b.screen_shadow_pos,b.shadow_pos)
end
function ball_draw(b)
    circfill(round(b.screen_shadow_pos.x),round(b.screen_shadow_pos.y),1,col.dark_blue)
    circfill(round(b.screen_pos.x),round(b.screen_pos.y),2,col.green)
end
function net(lines,cam)
    return {lines = lines,net_top = 1.5*meter,net_bottom = 0.9*meter,left_pole = -2.95*meter,right_pole = 2.95*meter,cam = cam,update = net_update,draw = net_draw}
end
function net_update(_n)
end
function net_draw(n)
    local i = 0
    while(i<#n.lines) do
        do
            local l = n.lines[i+1]

            line_draw(l,n.cam)
        end
        ::__continue15::
        i = (i+1)
    end
end
function net_collides_with(n,prev_pos,next_pos)
    if (not (((prev_pos.z>0) and (next_pos.z<0)) or ((prev_pos.z<0) and (next_pos.z>0)))) then
        return false,nil
    end
    local z0 = prev_pos.z

    local x_at_net = nil

    if (next_pos.x-prev_pos.x)<0.1 then
        x_at_net = prev_pos.x
    else
        local m = (next_pos.z-prev_pos.z)/(next_pos.x-prev_pos.x)

        local diff = -z0/m

        x_at_net = (prev_pos.x+diff)
    end
    local x_in_range = (n.left_pole<=x_at_net) and (x_at_net<=n.right_pole)

    if (not x_in_range) then
        return false,nil
    end
    local m2 = (next_pos.z-prev_pos.z)/(next_pos.y-prev_pos.y)

    local y = -z0/m2

    local y_at_net = prev_pos.y+y

    local y_in_range = (n.net_bottom<=y_at_net) and (y_at_net<n.net_top)

    if (not y_in_range) then
        return false,nil
    end
    return true,vec3(x_at_net,y_at_net,0)
end
function court(court_lines,cam)
    local p = polygon(col.dark_green,cam,{vec3(-3.8*meter,0,-7.7*meter),vec3(-3.8*meter,0,7.7*meter),vec3(3.8*meter,0,7.7*meter),vec3(3.8*meter,0,-7.7*meter)})

    local singles_even_bounds = {vec3(0,0,1.98*meter),vec3(2.59*meter,0,6.7*meter)}

    local singles_odd_bounds = {vec3(-2.59*meter,0,1.98*meter),vec3(0,0,6.7*meter)}

    return {court_lines = court_lines,cam = cam,update = court_update,draw = court_draw,poly = p,singles_even_bounds = singles_even_bounds,singles_odd_bounds = singles_odd_bounds}
end
function court_update(c)
    polygon_update(c.poly)
end
function court_draw(c)
    polygon_draw(c.poly)
    local i = 0
    while(i<#c.court_lines) do
        do
            local l = c.court_lines[i+1]

            line_draw(l,c.cam)
        end
        ::__continue16::
        i = (i+1)
    end
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
