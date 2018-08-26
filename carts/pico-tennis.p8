pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pico tennis
-- by paranoid cactus

function _init()
	settings = {1,1,2,3}
	next_game_state = 3
	logo_timer = 60
	sfx(7)
end

function _update60()
	game_state = next_game_state

	if game_state == 0 then
    -- start screen
		update_game()
		update_menu(main_menu,0)
	elseif game_state == 1 then
    -- character selection
		update_game_settings()
	elseif game_state == 2 then
    -- actual game
		update_game()
	elseif game_state == 3 then
    -- dev logo
		logo_timer -= 1
		if logo_timer <= 0 then
			next_game_state = 0
			init_world()
			init_player_pool()
			init_main_menu()
		end
	end
end

function _draw()
	if (game_state ~= next_game_state) return
	cls(1) -- dark blue
	if game_state == 0 then
    -- start screen
		cls(13) -- indigo, which is like a dull purple
		draw_game()
		sspr(0,64,105,40,12,1) -- game logo
		draw_menu(main_menu,4,91)
		sspr(0,110,30,12,96,114) -- dev logo
	elseif game_state == 1 then
    -- character selection
		draw_game_settings()
	elseif game_state == 2 then
    -- actual game
		draw_game()
	elseif game_state == 3 then
    -- dev logo
		cls(0)
		sspr(72,104,30,22,47,50)
	end
end
-->8
-- main menu
function init_main_menu()
	player_count = 2
	total_sets_list = {1,3,5}
	new_game(true)
	main_menu = {
		selected_index = 1,
    scroll_offset  = 1,
    visible_items  = 4,

		{"play",      0, init_game_settings},
		{"type",      1, settings,          1, {"singles","doubles"}},
		{"set score", 1, settings,          2, {3,6}},
		{"sets",      1, settings,          3, total_sets_list},
		{"cpu",       1, settings,          4, {"stupid","easy","normal","hard","pro"}}
	}
	menu_current = main_menu
	next_game_state = 0
	music(0)
end

function update_menu(menu,controller)
	local selected_option = menu[menu.selected_index]
	local val3,val4 = selected_option[3],selected_option[4]
	if selected_option[2] == 0 then
		if btnp(4,controller) then -- play game
			val3(val4)
		end
	else
		if btnp(0,controller) then -- left
			val3[val4] = val3[val4] == 1 and #selected_option[5] or val3[val4]-1
		end
		if btnp(1,controller) then -- right
			val3[val4] = val3[val4]% #selected_option[5] + 1
		end
	end
	if btnp(2,controller) then -- up
		menu.selected_index = menu.selected_index == 1 and #menu or menu.selected_index-1
	end
	if btnp(3,controller) then -- down
		menu.selected_index = menu.selected_index%#menu+1
	end
	if menu.selected_index < menu.scroll_offset then
		menu.scroll_offset = menu.selected_index
	elseif menu.selected_index > menu.scroll_offset+menu.visible_items then
		menu.scroll_offset = menu.selected_index-menu.visible_items
	end
end

function draw_menu(menu,x,y)
	local top = y
	rectfill(x-2,y-2,x+50,y+menu.visible_items*7+6,1)
	for i=menu.scroll_offset,min(menu.scroll_offset+menu.visible_items,#menu) do
		local menu_item,txt_col = menu[i],6
		if menu.selected_index == i then
			rectfill(x-1,y-1,x+49,y+5,12)
			txt_col = 7
		end
		print(menu_item[1],x,y,txt_col)
		if menu_item[6] then
			menu_item[6](x+#menu_item[1]*4,y,menu_item[3][menu_item[4]],menu_item[5])
		elseif menu_item[2] == 1 then
			local str = ""..menu_item[5][menu_item[3][menu_item[4]]]
			print(str,x+50-#str*4,y,7)
		end
		y += 7
	end
	if menu.scroll_offset > 1 then
	--if true then
    -- draws an up arrow at the top
		sspr(67,107,5,4,x+45,top-4)
	end
	if menu.scroll_offset+menu.visible_items < #menu then
  --if true then
    -- draws a down arrow at the bottom
		sspr(67,104,5,4,x+45,y-2)
	end
end

-->8
-- game settings
function read_color_range(x,y,count,set_size)
	local color_range = {}
	for i=1,count do
		local set = {}
		for j=1,set_size do
			add(set,sget(x,y))
			x += 1
		end
		add(color_range,set)
	end
	return color_range
end

function init_player_pool()
	color_sets = { read_color_range(0,8,7,2),read_color_range(0,9,2,1),read_color_range(0,10,6,2),read_color_range(0,11,7,1) }
	
	player_count = 2
	
	inactive_controllers = {0,1,2,3,4,5,6,7}
	inactive_player_settings = {}
	active_player_settings = {}
	
	player_settings = {}
	for i=1,4 do
		local p = add(inactive_player_settings,add(player_settings, { 
			index = i,
			controller = nil,
			selected_option = 1,
			colors = {
				flr(rnd(#color_sets[1]))+1,
				flr(rnd(#color_sets[2]))+1,
				flr(rnd(#color_sets[3]))+1,
				flr(rnd(#color_sets[4]))+1
				}
			}))
		p.player = new_player(0,0,0.5,p.colors,nil,(i-1)%2+1)
		p.menu = {
			selected_index = 1,scroll_offset=1,visible_items=3,
			-- label,type,value_table,value_key,display_values,[special_draw_func]
			{"ready",0,ready_player,p},
			{"suit ",1,p.colors,1,color_sets[1],draw_color_range},
			{"skin ",1,p.colors,2,color_sets[2],draw_color_range},
			{"hair ",1,p.colors,3,color_sets[3],draw_color_range},
			{"eyes ",1,p.colors,4,color_sets[4],draw_color_range},
			{"back out",0,remove_player,p}
		}
	end
end

function init_game_settings()
	player_count = settings[1]*2
	
	inactive_controllers = {0,1,2,3,4,5,6,7}
	inactive_player_settings = {}
	active_player_settings = {}
	
	for k,v in pairs(player_settings) do
		v.player = new_player(0,0,0.5,v.colors,nil,(k-1)%2+1)
		v.menu.selected_index = 1
		add(inactive_player_settings,v)
	end
		
	add_player(0)
	
	camera_distance = 120
	camera_angle = 0
	camera_pos = new_vector3d(0,-8,0)
	mx,my = matrix_rotate_x(-0.1),matrix_rotate_y(camera_angle)
	next_game_state = 1
end

function update_game_settings()
	local ready_count,active_count = 0,#active_player_settings
	for k,v in pairs(active_player_settings) do
		update_menu(v.menu,v.controller)
		
		-- count the number of ready players
		if v.ready then
			ready_count += 1
		end
	end
	
	-- check unassaigned controllers for new players (unless a player has left this frame)
	if #active_player_settings == active_count and active_count < player_count and #inactive_player_settings >= 1 then
		for k,v in pairs(inactive_controllers) do
			if btnp(4,v) then
				add_player(v)
			end
		end
	end
	
	if #active_player_settings == 0 then
		init_main_menu()
		return
	elseif ready_count == #active_player_settings then
		new_game()
		return
	end
	
	-- rotate player models
	for k,v in pairs(player_settings) do
		v.player.angle += 0.0125
		if v.player.angle > 1 then
			v.player.angle -= 1
		end
		update_player(v.player)
	end
end

function add_player(controller)
	inactive_player_settings[1].controller = controller
	del(inactive_player_settings,add(active_player_settings,inactive_player_settings[1]))
	if controller then
		del(inactive_controllers,controller)
	end
end

function remove_player(player)
	if player.controller then
		add(inactive_controllers,player.controller)
	end
	player.controller = nil
	player.ready = false
	player.menu.selected_index = 1
	local insert_index = 0
	for j=1,#inactive_player_settings do
		insert_index = j
		if inactive_player_settings[j].index > player.index then
			break
		end
	end
	table_insert(inactive_player_settings,player,insert_index)
	del(active_player_settings,player)
end

function ready_player(p)
	p.ready = true
end

function draw_color_range(x,y,selected,r)
	rectfill(x,y,x+#r*4,y+4,0)
	rect(x+(selected-1)*4,y,x+(selected-1)*4+4,y+4,7)
	x += 1
	y += 1
	for i=1,#r do
		rectfill(x,y,x+2,y+2,r[i][1])
		if r[i][2] then
			rectfill(x,y,x+2,y+1,r[i][2])
		end
		x += 4
	end
end

function draw_player_settings(x,y,player_setting,index)
	rectfill(x+6,y+25,x+58,y+31,0)
	if player_setting.controller == nil then
		print("cpu "..index,x+9,y+26,7)
		rectfill(x+6,y+32,x+58,y+61,5)
		print("press",x+22,y+38,6)
		print("button",x+20,y+44,6)
		print("to join",x+18,y+50,6)
	else
		print("player "..index,x+9,y+26,7)
		if player_setting.ready then
			rectfill(x+6,y+32,x+58,y+61,2)
			print("ready",x+22,y+44,7)
		else
			draw_menu(player_setting.menu,x+8,y+34)
		end
	end
	camera(-x+32,-y+36)
	player_setting.player:draw()
	camera()
end

function draw_game_settings()
	cls(3)
	local x,y = 0,0
	if player_count < 3 then
		y = 32
	end
	for i=1,player_count do
		draw_player_settings(x,y,player_settings[i],i)
		x += 63
		if x > 64 then
			x = 0
			y += 64
		end
	end
end
-->8
-- game & ball
function new_game(is_demo)
	if is_demo then
		camera_distance = 160
		camera_pos = new_vector3d(0,8,0)
		camera_angle_x = -0.065
		no_control_timer = 1
		ai_dumbness = 10
	else
		camera_distance = 120
		camera_pos = new_vector3d(0,-5,0)
		camera_angle_x = -0.1
		no_control_timer = 240
		menuitem(1,"end match",end_match)
		ai_dumbness = (5-settings[4])*7.5
	end
	
	set_score_min = settings[2]*3
	total_sets = total_sets_list[settings[3]]
	
	camera_angle = 0
	camera_lerp_angles = {-0.25,0}
	camera_lerp_amount = 0
	
	score_text = {"0","15","30","40","adv"}
	court_bounds = {new_vector3d(-46,0,-64),new_vector3d(46,0,64)}

	if (pos_data_cycled) cycle_pos_data()
	receiver_data = player_count == 2 and singles_data or doubles_data
	
	game_score = {0,0}
	set_score = {0,0}
	set_scores = {{0,0}}
	match_score = {{0,0}}
	players = {}
	
	for i=#active_player_settings+1,player_count do
		add_player()
	end
	
	local team_index,team_member_index = 1,1
	team_size = player_count/2
	serving_team = 2
	serving_team_member = 1
	local player_num,cpu_num = 1,1
	
	for k,v in pairs(active_player_settings) do
		local player = v.player
		player.court_side = team_index
		player.team = team_index
		player.team_member_index = team_member_index
		if v.controller then
			player.input = player_input_keyboard
			player.name = "player "..player_num
			player_num += 1
		else
			player.input = player_input_ai
			player.name = "cpu "..cpu_num
			cpu_num += 1
		end
		player.controller = v.controller
		player.pos_data = team_index==serving_team and server_data[team_index][team_member_index] or receiver_data[team_index][team_member_index]
		player.pos = player.pos_data.start_pos
		player.angle = player.pos_data.start_angle
		player.mode = 2
		player.move_to = {}
		player.teammate = nil
		player.power = 0
		
		add(players,v.player)
		
		team_member_index += 1
		if team_member_index > team_size then
			team_index += 1
			team_member_index = 1
		end
	end

	if team_size == 2 then
		players[1].teammate = players[2]
		players[2].teammate = players[1]
		players[3].teammate = players[4]
		players[4].teammate = players[3]
	end
	
	rotate_camera = player_num == 0 or player_num-1 <= player_count / 2
	service = players[(serving_team-1)*team_size+serving_team_member]
	change_sides = true
	serve_num = 0
	message_func = nil
	timer_expired_func = continue_match
	
	new_ball(0,-100,0)
	ball.vel.z = -service.facing*0.0001
	
	next_game_state = 2
	ai_think_next_frame = false
	ai_think = false
	music(-1,60)
end

function continue_match()
	service.mode = 0
	ball.service = true
	message_func = nil
end

function return_to_mainmenu()
	menuitem(1)
	init_player_pool()
	init_main_menu()
end

function start_new_game()
	new_game(true)
end

function update_game()
	if game_state ~= 2 then
		camera_angle = (camera_angle+0.0025)%1
	elseif camera_lerp_amount < 1 then
		camera_lerp_amount = min(camera_lerp_amount+0.005,1)
		camera_angle = smooth_lerp(camera_lerp_angles[1],camera_lerp_angles[2],camera_lerp_amount)
	end
	
	ai_think = ai_think_next_frame
	ai_think_next_frame = false
	
	--camera_normal = v3d_normal(new_vector3d(sin(camera_angle),0,-cos(camera_angle)))
	
	-- get camera view matrices
	mx,my = matrix_rotate_x(camera_angle_x),matrix_rotate_y(camera_angle)
	
  -- jason: update screen points of polygons
	for poly_i,poly in pairs(polys) do
		for i,p in pairs(poly.points_3d) do
			poly.points_scr[i] = translate_to_view(p)
		end
	end
	
	translate_lines(court_lines,lines_scr)
	translate_lines(net,net_scr)
	
	z_sorted_objects = { net_scr }
	
	for k,v in pairs(players) do
		update_player(v)
		table_insert(z_sorted_objects,v,get_sort_index(v))
	end
	
	update_ball()
	table_insert(z_sorted_objects,ball,get_sort_index(ball_shadow))
	
	if no_control_timer > 0 then
		no_control_timer -= 1
		if no_control_timer <= 0 then
			for k,v in pairs(players) do
				v.mode = 1
			end
			timer_expired_func()
		end
	end
end

function translate_lines(line_table,scr_table)
	for k,v in pairs(line_table) do
		scr_table[k] = {
			translate_to_view(v[1]),
			translate_to_view(v[2]),
			v[3]
		}
	end
end

function draw_game()
	for k,v in pairs(polys) do
		draw_polygon(v)
	end

	draw_lines(lines_scr)
	
	for k,p in pairs(players) do
		if p.shadow_pos_scr then
			local sprite = p.sprite_model[7].sprites.sprites[1]
			draw_shadow(sprite[1],sprite[2],p.sprite_model[7].sprites.width,p.sprite_model[7].sprites.height,p.shadow_pos_scr.x+sprite[3],p.shadow_pos_scr.y+sprite[4])
		end
	end
	
	draw_shadow(8,56,5,4,ball_shadow.pos_scr.x-2,ball_shadow.pos_scr.y-1)
	
	for i=1,#z_sorted_objects do
		z_sorted_objects[i]:draw()
	end

	if game_state == 2 then
		for k,v in pairs(players) do
			local x,power_x,power_y,y,score_y = 0,2,7,1,0
			if v.pos_data.start_pos.x*v.move_dir > 0 then
				x = 125-#v.name*4
				power_x = 110
			end
			if v.camera_side > 0 then
				score_y = 122
				y = 122
				power_y = 117
			end
			local right = x+(#v.name*4)
			palt(0,false)
			palt(2,true)
			sspr(0,12+v.power*16,16,4,power_x,power_y) -- draws power meter
			sspr(game_score[v.team]*13,104,15,6,57,score_y) -- draws score
			palt()
			rectfill(x,y-2,right+2,y+6,0) -- draw name bg
			rectfill(x-1,y-1,right+3,y+5,0) -- also draw name bg
			print(v.name,x+2,y,color_sets[1][v.colors[1]][2]) -- draw name
		end

		if (message_func) message_func()
	end
end

function draw_big_text(text,x,y)
	local text_data,width = {},1
	for i=1,#text do
		text_data[i] = chars[sub(text,i,i)]
		width += text_data[i][3]-1
	end
	x -= width/2
	for i=1,#text_data do
		local td = text_data[i]
		sspr(td[1],td[2],td[3],td[4],x,y)
		x += td[3]-1
	end
end

function draw_big_messages(y)
	if message_text then
		draw_big_text(message_text,63,y)
		y -= 13
	end
	if message_reason then
		pal(1,2)
		pal(5,8)
		pal(12,9)
		pal(6,10)
		draw_big_text(message_reason,63,y)
		pal()
	end
end

function get_game_score_text()
	local score1,score2 = game_score[service.team]+1,game_score[service.team%2+1]+1
	if score1 == 4 and score1 == score2 then
		return "deuce"
	elseif score1 > 4 then
		return "adv in"
	elseif score2 > 4 then
		return "adv out"
	else
		return (score_text[score1].." - "..score_text[score2])
	end
end

function draw_message()
	draw_big_messages(43)
	if message_show_score then
		local score_text = get_game_score_text()
		local half_width = (#score_text*4)/2
		rectfill(58-half_width,56,66+half_width,64,7)
		print(score_text,63-half_width,58,0)
	end
end

function draw_set_score()
	draw_big_messages(32)
	draw_score_board(set_scores,"set")
end

function draw_match_score()
	draw_big_messages(32)
	draw_score_board(match_score,"match")
end

function get_team_name(team_num)
	local team_names = {players[1].name,players[2].name}
	if player_count == 4 then
		team_names[1] = get_short_name(team_names[1])..","..get_short_name(team_names[2])
		team_names[2] = get_short_name(players[3].name)..","..get_short_name(players[4].name)
	end
	return team_names[team_num]
end

function get_short_name(str)
	return sub(str,1,1)..sub(str,#str,#str)
end

function draw_score_board(scores,title)
	local team1name,team2name = get_team_name(1),get_team_name(2)
	if #scores > 8 and player_count == 2 then
		team1name = get_short_name(team1name)
		team2name = get_short_name(team2name)
	end
	local namelen = max(#team1name,#team2name)*4
	local x = 63-(namelen+#scores*8)/2
	local right = x+namelen+#scores*8+1
	rectfill(x+namelen+4,54,right,72,7)
	rectfill(right-6,54,right,72,12)
	rectfill(x+namelen+4,63,right-7,63,6)
	for i=1,#scores do
		local x2,txtcol = x+namelen+i*8-2,0
		if i == #scores then
			txtcol = 7
			x2 -= 1
		else
			rectfill(x2-3,54,x2-3,72,6)
		end
		print(scores[i][1],x2,56,txtcol)
		print(scores[i][2],x2,66,txtcol)
	end
	rectfill(x,45,right,53,0)
	print(title,x+2,47,7)
	rectfill(x,54,x+namelen+3,72,12)
	print(team1name,x+2,56,7)
	print(team2name,x+2,66,7)
end

function update_game_score(team,text)
	if no_control_timer <= 0 then
		
		message_reason = text
		message_text = nil
		message_show_score = true
		
		local other_team = team%2+1
		no_control_timer = 120
		for k,v in pairs(players) do
			v.move_to = {}
		end
		
		if ball.bounce_count <= 1 then
			if serve_num == 1 then
				message_reason = "fault"
				message_func = draw_message
				service.pos_data = server_data[service.court_side][service.team_member_index]
				for k,v in pairs(players) do
					v.angle = v.pos_data.start_angle
					v.move_to = {v.pos_data.start_pos}
					v.mode = 2
				end
				message_show_score = false
				return
			elseif serve_num == 2 then
				message_reason = "double fault"
			end
		end
		
		message_text = get_team_name(team).." point"
		
		serve_num = 0
		message_func = draw_message
		
		if game_score[team] == 3 then
			if game_score[other_team] == 4 then
				game_score[other_team] -= 1
			else
				game_score[team] += 1
				
				if game_score[other_team] ~= 3 then
					end_game(team)
				end
			end
		elseif game_score[team] == 4 then
			game_score[team] += 1
			end_game(team)
		else
			game_score[team] += 1
		end
		
		-- players switch between left and right sides
		cycle_pos_data()

		-- move players for service
		for k,v in pairs(players) do
			v.power = 0
			v.pos_data = v.team==serving_team and server_data[v.court_side][v.team_member_index] or receiver_data[v.court_side][v.team_member_index]
			v.angle = v.pos_data.start_angle
			add(v.move_to,v.pos_data.start_pos)
			v.mode = 2
			if (v.team == serving_team and v.team_member_index == serving_team_member) service = v
		end

		ball.last_hit_player = nil
	end
end

function cycle_pos_data()
	for i=1,2 do
		for j=1,2 do
			local s,r = server_data[i][1],receiver_data[i][1]
			del(server_data[i],s)
			add(server_data[i],s)
			del(receiver_data[i],r)
			add(receiver_data[i],r)
		end
	end
	pos_data_cycled = not pos_data_cycled
end

function end_game(team)
	set_score[team] += 1
	set_scores[#set_scores] = {0,0}
	set_scores[#set_scores][team] = 1
	add(set_scores,{set_score[1],set_score[2]})
	
	change_sides = (set_score[1]+set_score[2])%2==1

	message_func = draw_set_score
	no_control_timer = 240
	
	if max(set_score[1],set_score[2]) >= set_score_min then
		local score_dif = set_score[1]-set_score[2]

		if score_dif >= 2 or set_score[1] == set_score_min+1 then
			-- team 1 victory
			end_set(1)
		elseif score_dif <= -2 or set_score[2] == set_score_min+1 then
			-- team 2 victory
			end_set(2)
		end
	end
	
	-- switch player service
	serving_team = serving_team%2+1
	if serving_team == 1 then
		for k,v in pairs(players) do
			v.team_member_index = v.team_member_index%team_size+1
		end
	end
	
	-- change sides after each odd numbered game
	if (set_score[1]+set_score[2])%2==1 then
		for k,v in pairs(players) do
			v.court_side = v.court_side%2+1
			-- move around the net
			if v.pos.z < 0 then
				v.move_to = {new_vector3d(40,0,-8),new_vector3d(40,0,8)}
			else
				v.move_to = {new_vector3d(-40,0,8),new_vector3d(-40,0,-8)}
			end
			if rotate_camera then
				camera_lerp_angles = camera_angle < 0.5 and {0,0.5} or {0.5,0}
				camera_lerp_amount = 0
			end
		end
	end
	
	game_score = {0,0}
	
	if (not pos_data_cycled) cycle_pos_data()
end

function end_set(team)
	message_func = draw_match_score
	no_control_timer = 360
	
	local team_scores = match_score[#match_score]
	if set_score[1] > set_score[2] then
		team_scores[1] += 1
	else
		team_scores[2] += 1
	end
	match_score[#match_score] = {set_score[1],set_score[2]}

	add(match_score,team_scores)
	
	if #match_score == total_sets+1 then
		end_match(team_scores[1]>team_scores[2] and 1 or 2)
	end
	set_score = {0,0}
	set_scores = {{0,0}}
end

function end_match(team)
	if team then
		no_control_timer = 480
		message_text = get_team_name(team).." wins"
	else
		no_control_timer = 1
	end
	if game_state ~= 2 then
		timer_expired_func = start_new_game
	else
		timer_expired_func = return_to_mainmenu
	end
end

-- ball
function new_ball(x,y,z)
	ball = {
		pos = new_vector3d(x,y,z),
		vel = new_vector3d(),
		bounce_pos = new_vector3d(),
		bounce_count = 0,
		service = true,
		draw = draw_ball,
		behind = behind_point
	}
	ball_shadow = {
		pos = new_vector3d(x,0,z),
		draw = draw_ball_shadow,
		behind = behind_point
	}
	particles = {}
	particle_colors = {{8,8,9,10},{8,9,10,7},{13,14,6,7},{12,12,6,7}}
end

function update_ball()
	if not ball.service then
		local scored = false
		ball.vel.y += 0.06
		
		-- hit net
		if ball.pos.y >= -6 
			and (ball.pos.z > 0) ~= (ball.pos.z + ball.vel.z > 0)
			and (ball.pos.x >= -32 and ball.pos.x <= 32) then
			ball.pos.z -= ball.vel.z
			ball.vel = new_vector3d()
			if ball.last_hit_player then
				update_game_score(ball.last_hit_player.team%2+1,"net")
			end
			scored = true
			ball.on_fire = false
		end
		
		ball.pos = v3d_add(ball.pos,ball.vel)
		
		-- bounce
		if ball.pos.y > 0 then
			if (game_state ~= 0 and ball.vel.y > 0.23) sfx(1)
			ball.vel.y = -ball.vel.y*0.75
			ball.pos.y = -ball.pos.y
			ball.bounce_count += 1
			if ball.last_hit_player then
				if not scored then
					-- second bounce
					if ball.bounce_count >= 2 then
						update_game_score(ball.last_hit_player.team)
						scored = true
					-- bounce out of valid court area
					elseif not point_in_rect(ball.pos,ball.valid_hit_region[1],ball.valid_hit_region[2]) then
						update_game_score(ball.last_hit_player.team%2+1,"out")
						scored = true
					end
				end
			else
				-- failed to hit the ball on serve
				if service.mode == 3 then
					ball.service = true
					service.mode = 0
					ball.bounce_count = 0
				end
			end
		end
		-- out of bounds on the full
		if not scored and not point_in_rect(ball.pos,court_bounds[1],court_bounds[2]) then
			if ball.last_hit_player then
				if ball.bounce_count == 1 then
					ball.bounce_count += 1
					update_game_score(ball.last_hit_player.team)
				else
					update_game_score(ball.last_hit_player.team%2+1,"out")
				end
			end
			ball.vel.x = 0
			ball.vel.z = 0
			ball.on_fire = false
		end
	else
		-- position to service player's hand (requires rotation the bone to the player's angle)
		ball.pos = v3d_add(
      service.pos,
      matrix_mul_add(matrix_rotate_x(0),
        matrix_mul_add(
          matrix_rotate_y(-service.angle),
          service.sprite_model[5].pos
        )
      )
    )
	end
	
	ball_shadow.pos.x = ball.pos.x
	ball_shadow.pos.z = ball.pos.z
	ball.pos_scr = translate_to_view(ball.pos)
	ball_shadow.pos_scr = translate_to_view(ball_shadow.pos)
	
	for k,v in pairs(particles) do
		v.time -= 1
		if v.time <= 0 then
			del(particles,v)
		else
			table_insert(z_sorted_objects,v,get_sort_index(v))
		end
	end
	
	if ball.on_fire then
		local p_pos = v3d_sub(ball.pos,new_vector3d(0,2,0))
		for i=0,1 do
			local p,pi = add(particles,{pos_scr=translate_to_view(v3d_add(p_pos,v3d_mul_num(ball.vel,i/-2))),time = 20,col=ball.on_fire,draw=draw_particle,behind = behind_point}),get_sort_index(ball)
			table_insert(z_sorted_objects,p,pi)
		end
	end
end

function draw_particle(p)
	local size = (p.time/20)*1.85
	circfill(p.pos_scr.x,p.pos_scr.y,size,
    particle_colors[p.col][
      flr(p.time/20*(#particle_colors[p.col]-1))+1
    ]
  )
end

function calculate_bounce_point()
	local vel,pos = v3d_mul_num(ball.vel,1),v3d_mul_num(ball.pos,1)
	while pos.y < 0 do
		vel.y += 0.06
		pos = v3d_add(pos,vel)
	end
	pos.y = 0
	return pos
end

function draw_ball(b)
	sspr(0,56,5,5,b.pos_scr.x-2,b.pos_scr.y-4)
end
-->8
-- player
function new_player(x,z,angle,colors,input_function,team)
	return {
		pos = new_vector3d(x,0,z),
		angle = angle,
		vel = new_vector3d(),
		team = team,
		move_dir = 1,
		camera_side = 1,
		input = input_function,
		draw = draw_player,
		behind = behind_point,
		leg_anim = anims[1],
		leg_anim_time = 0,
		arm_anim = anims[6],
		arm_anim_time = 0,
		swing_timer = 0,
		power = 0,
		mode = 1,
		move_to = {},
		ai_hit_distance = 10,
		ai_delay = 0,
		swing_dir = 1,
		ball_path_distance = 0,
		facing = z < 0 and 1 or -1,
    -- player is a series of parts
		sprite_model = {
			new_sprite_container(sprites[2],0,-3,0,0),
			new_sprite_container(sprites[3],2.5,-4,-1.5,0.125),
			new_sprite_container(sprites[4],-1.25,0,0,0.125),
			new_sprite_container(sprites[4],1.25,0,0,-0.125),
			new_sprite_container(sprites[5],-2.5,-4,-1,0),
			new_sprite_container(sprites[6],2.5,-4,-1,0),
			new_sprite_container(sprites[1],0,2,0,0)
		},
		colors = colors
	}
end

function update_player(p)
	p.facing = p.pos.z < 0 and 1 or -1
	if p.input then
		if camera_angle < 0.25 or camera_angle > 0.75 then
			p.move_dir = 1
		else
			p.move_dir = -1
		end
		if (p.pos.z < 0) == (camera_angle < 0.25 or camera_angle > 0.75) then
			p.camera_side = -1
		else
			p.camera_side = 1
		end
		
		p.ball_path_distance = orient2d_xz(ball.pos,v3d_add(ball.pos,ball.vel),p.pos)
		
		if p.mode == 2 then
			if #p.move_to >= 1 then
				if player_move_to(p,p.move_to[1],2) then
					del(p.move_to,p.move_to[1])
					if #p.move_to == 0 then
						p.angle = p.pos_data.start_angle
					end
				else
					local normal = v3d_normal(v3d_sub(p.move_to[1],p.pos))
					p.angle = atan2(-normal.z,normal.x)
				end
			end
		else
			p:input()
		end

		local new_pos = v3d_add(p.pos,p.vel)

    -- bounds checking
		if p.mode ~= 2 then
			if p.vel.z < 0 and new_pos.z < p.pos_data.move_region[2] then
				new_pos.z = p.pos_data.move_region[2]
				p.vel.z = 0
			end
			if p.vel.z > 0 and new_pos.z > p.pos_data.move_region[4] then
				new_pos.z = p.pos_data.move_region[4]
				p.vel.z = 0
			end
			if p.vel.x < 0 and new_pos.x < p.pos_data.move_region[1] then
				new_pos.x = p.pos_data.move_region[1]
				p.vel.x = 0
			end
			if p.vel.x > 0 and new_pos.x > p.pos_data.move_region[3] then
				new_pos.x = p.pos_data.move_region[3]
				p.vel.x = 0
			end
		end
		
		-- set animations
		if v3d_length(p.vel) < 0.1 then
			-- not moving
			p.leg_anim = anims[1]
			if p.leg_anim_time > p.leg_anim[#p.leg_anim].to_time then
				p.leg_anim_time = 0
			end
		else
			-- if moving
			local move_angle = atan2(-p.vel.z,p.vel.x)-p.angle+0.125
			p.leg_anim = anims[flr((move_angle < 0 and move_angle+1 or (move_angle >= 1 and move_angle-1 or move_angle)*4))+2]
		end

		p.pos = new_pos
		p.vel = v3d_mul_num(p.vel,0.8)
		
		if p.ball_path_distance > 0 or ball.vel.z == 0 or (ball.vel.z > 0) == (p.facing > 0) then
			p.swing_dir = 1
		else
			p.swing_dir = -1
		end

    -- set some animations
		if p.swing_timer <= 0 then
			if p.mode == 3 then
				if p.arm_anim ~= anims[10] then
					p.arm_anim_time = 0
				end
				p.arm_anim = anims[10]
			elseif p.swing_dir >= 0 or p.mode == 0 or p.mode == 4 then
				if p.arm_anim ~= anims[6] then
					p.arm_anim_time = 0
				end
				p.arm_anim = anims[6]
			else
				if p.arm_anim ~= anims[7] then
					p.arm_anim_time = 0
				end
				p.arm_anim = anims[7]
			end
		end

		if p.swing_timer > 0 then
			-- hit the ball
			if p.swing_timer == 30 and (ball.vel.z == 0 or (ball.vel.z > 0) ~= (p.facing > 0)) then
				p.arm_anim_time = 0
				if p.arm_anim == anims[10] then
					p.arm_anim = anims[11]
				elseif p.swing_dir < 0 then
					p.arm_anim = anims[9]
				else
					p.arm_anim = anims[8]
				end
				local ball_distance,hit_range = v3d_distance2d(p.pos,ball.pos),get_swing_dist(p.pos.z,p.move_dir)
				if ball_distance <= hit_range then
					local power,direction,vert = (
            1.3+abs(p.pos.z/58)*0.7+(ball_distance/hit_range)*0.2,
            abs(ball.pos.x-p.pos.x)/(hit_range*2.5)*-p.swing_dir*p.move_dir*p.camera_side+(-ball.pos.x/64)*1.2,
            (ball.pos.y/18+lerp(0.9,1.0,abs(p.pos.z/58)*0.5+(ball_distance/hit_range*0.4)))*-1.25
					ball.on_fire = false
					if p.power_shot then
						power += p.power*1.65
						ball.pos.y = lerp(-16,-18,p.power)						
						direction *= (p.power*0.9-1)*-1
						vert = lerp(0.1,-0.15,abs(p.pos.z/58))+p.power*0.15
						ball.on_fire = min(max(round(p.power*4),1),#particle_colors)
						if (game_state ~= 0) sfx(6)
						p.power = -0.25
						p.arm_anim = anims[11]
					elseif p == service and serve_num > 0 then
						vert = ball.pos.y/-18*0.5-0.7
					end
					if (game_state ~= 0) sfx(2+rnd(3))
            -- *** set ball velocity ***
					ball.vel = v3d_mul_num(
						v3d_normal(
							new_vector3d(direction,
							vert,
							p.facing)),power)
					ball.bounce_count = 0
					ball.last_hit_player = p
					ball.bounce_pos = calculate_bounce_point()
					ball.valid_hit_region = p.pos_data.valid_hit_region
					ai_think_next_frame = true
					service.pos_data = receiver_data[service.court_side][service.team_member_index]
					p.power_shot = false
					if (p ~= service) serve_num = 0
					if serve_num == 0 then
						p.power = min(p.power+0.25,1)
					end
				elseif game_state ~= 0 then
					sfx(0)
				end
			end
			p.swing_timer -= 1
		end
		
		local new_leg_anim,new_arm_anim = nil,nil
		p.leg_anim_time,new_leg_anim = animate_limbs(p.sprite_model,p.leg_anim,p.leg_anim_time + 1)
		p.arm_anim_time,new_arm_anim = animate_limbs(p.sprite_model,p.arm_anim,p.arm_anim_time + 1)
		
		if new_leg_anim then
			p.leg_anim = new_leg_anim
		end
		if new_arm_anim then
			p.arm_anim = new_arm_anim
		end
	end
	
	-- prepare for rendering
	local m_player_rotation_x, m_player_rotation_y = matrix_rotate_x(0),matrix_rotate_y(-p.angle)
	p.pos_scr = translate_to_view(p.pos)
	p.sprite_model_sorted = {}
  --print(#p.sprite_model)
  --stop()
	for k,v in pairs(p.sprite_model) do
		v.pos_scr = translate_to_view(v3d_add(p.pos,matrix_mul_add(m_player_rotation_x,matrix_mul_add(m_player_rotation_y,v.pos))))
		v.pos_scr.x = round(v.pos_scr.x)
		
		if k == 7 then
			p.shadow_pos_scr = v.pos_scr
		else
			local insert_i = 0
			for i=1,#p.sprite_model_sorted do
				if v.pos_scr.z <= p.sprite_model_sorted[i].pos_scr.z then
					insert_i = i
					break
				end
			end
			table_insert(p.sprite_model_sorted,v,insert_i)
		end
	end
end

function get_swing_dist(z,cam_dir)
	return 11.5+(z/120*-cam_dir)*6
end

function player_input_keyboard(p)
	local move_speed = 0.175 * p.move_dir
	if btn(0,p.controller) then
		p.vel.x -= move_speed
	end
	if btn(1,p.controller) then
		p.vel.x += move_speed
	end
	if btn(2,p.controller) then
		p.vel.z -= move_speed
	end
	if btn(3,p.controller) then
		p.vel.z += move_speed
	end
	if btn(4,p.controller) then
		if not p.is_swing_pressed then
			p.power_shot = false
			p.is_swing_pressed = true
			if p.mode == 0 then
				serve(p)
				p.mode = 3
			elseif p.mode == 3 then
				p.swing_timer = 30
				p.mode = 1
				serve_num += 1
			elseif p.swing_timer <= 0 then
				p.swing_timer = 30
			end
		end
	elseif btn(5,p.controller) then
		if not p.is_swing_pressed and p.power > 0 then
			p.is_swing_pressed = true
			p.swing_timer = 30
			p.power_shot = true
		end
	else
		p.is_swing_pressed = false
	end
end

function player_input_ai(p)
	if (ai_think) p.ai_delay = 0
	if p.ai_delay > 0 then
		p.ai_delay -= 1
		return
	end
	-- service mode
	if p.mode == 0 then
		p.move_to = {new_vector3d(p.pos_data.move_region[1]+rnd(p.pos_data.move_region[3]-p.pos_data.move_region[1]),0,p.pos_data.move_region[2]+rnd(p.pos_data.move_region[4]-p.pos_data.move_region[2]))}
		p.mode = 4
	-- service mode 2
	elseif p.mode == 4 then
		if player_move_to(p,p.move_to[1],2) then
			p.move_to = {}
			serve(p)
			p.ai_delay = 16+rnd(20)
			p.mode = 3
		end
	-- service mode 3
	elseif p.mode == 3 then
		p.swing_timer = 30
		p.mode = 1
		p.power_shot = false
		serve_num += 1
	elseif p.mode == 1 then
		if ai_think then
			if ball.last_hit_player and ball.last_hit_player.team ~= p.team
				and (not p.teammate or abs(p.ball_path_distance) <= abs(p.teammate.ball_path_distance)) then
				local back_dist = rnd(16)
				local dest = new_vector3d(ball.bounce_pos.x+ball.vel.x*back_dist+rnd(ai_dumbness)-ai_dumbness/2,0,ball.bounce_pos.z+ball.vel.z*back_dist+rnd(ai_dumbness)-ai_dumbness/2)
				if ball.valid_hit_region and not point_in_rect(ball.bounce_pos,ball.valid_hit_region[1],ball.valid_hit_region[2]) then
					dest = v3d_add(p.pos,v3d_mul_num(v3d_sub(dest,p.pos),0.5+rnd(0.5)))
				end
				p.move_to = {dest}
				local swing_dist = get_swing_dist(dest.z,p.move_dir)
				p.ai_hit_distance = swing_dist*0.5+rnd(swing_dist*0.5)
				p.ai_delay = rnd(ai_dumbness*2)
			end
		end
	
		if (ball.vel.z > 0) ~= (p.facing > 0) then
			if #p.move_to >= 1 then
				if player_move_to(p,p.move_to[1],1) then
					del(p.move_to,p.move_to[1])
				end
			end
			
			if p.swing_timer <= 0
				and v3d_distance2d(p.pos,ball.pos) <= p.ai_hit_distance
				and	(ball.valid_hit_region == nil or point_in_rect(ball.bounce_pos,ball.valid_hit_region[1],ball.valid_hit_region[2]))then
				p.swing_timer = 30
				if p.power > 0 and rnd(1)<=rnd(p.power) and rnd(ai_dumbness)<5 then
					p.power_shot = true
				end
			end
		end
	end
end

function serve(p)
	new_ball(p.pos.x,-3,p.pos.z + p.facing*6)
	ball.vel.y = -1.1
	ball.vel.z = -p.facing*0.01
	ball.service = false
	p.is_swing_pressed = true
	p.swing_timer = 0
	if (game_state ~= 0) sfx(5)
end

function player_move_to(p,destination,nearness)
	local dist = v3d_distance2d(p.pos,destination) - nearness
	if dist > 0.001 then
		local normal = v3d_normal(v3d_sub(destination,p.pos))
		p.vel = v3d_add(p.vel,v3d_mul_num(normal,0.175))
		if dist < v3d_length(p.vel) then
			p.vel = v3d_mul_num(normal,dist)
		end
		return false
	end
	return true
end

function new_sprite_container(sprite_set,x,y,z,angle)
	return {
		sprites = sprite_set,
		pos = new_vector3d(x,y,z),
		angle = angle,
		pos_prev = new_vector3d(x,y,z),
		angle_prev = angle
	}
end

-- new_time is incremented
function animate_limbs(sprite_model,anim,new_time)
	local prev_frame,prev_frame_time = nil,0
	
	if new_time >= anim[#anim].to_time then
		if anim.loop then
			new_time = new_time%anim[#anim].to_time
			prev_frame = anim[#anim]
		else
      -- set pose to last frame
			set_pose(sprite_model,anim[#anim],anim[#anim],1)
			return 0,anim.on_finish ~= 0 and anims[anim.on_finish] or nil
		end
	end
	for i=1,#anim do
		if new_time < anim[i].to_time
			and new_time >= prev_frame_time then
				set_pose(sprite_model,prev_frame,anim[i],(new_time-prev_frame_time)/(anim[i].to_time-prev_frame_time))
			break
		end
		prev_frame = anim[i]
		prev_frame_time = anim[i].to_time
	end
		
	return new_time
end

function set_pose(sprite_model,prev_frame,next_frame,t)
	if prev_frame then
		for i=1,#prev_frame do
			local limb = sprite_model[prev_frame[i][1]]
			limb.pos_prev = prev_frame[i][2]
			limb.angle_prev = prev_frame[i][3]
			limb.sprites = sprites[prev_frame[i][4]]
		end
	end
	
  -- model pos and angle for limb
	for i=1,#next_frame do
		local limb = sprite_model[next_frame[i][1]]
		limb.pos = v3d_lerp(limb.pos_prev,next_frame[i][2],t)
		limb.angle = lerp(limb.angle_prev,next_frame[i][3],t)
		--if t >= 0.5 then
			limb.sprites = sprites[next_frame[i][4]]
		--end
	end
end

function draw_shadow(spx,spy,spw,sph,x1,y1)
	local x2,y2 = min(x1+spw,128),min(y1+sph,128)
	if not (x2 < 0 or x1 > 127 or y2 < 0 or y1 > 127) then
		local x1min,y1min = max(x1,0),max(y1,0)
		local draw_width,draw_height = x2-x1min,y2-y1min

    -- copy original area to spritesheet
		copy_to_spritesheet(x1min,y1min,y2,draw_width,0)

    -- draw mask to screen
		palt(0,false)
		palt(1,true)
		sspr(spx,spy,spw,sph,x1,y1,spw,sph)

    -- copy original area with black border to spritesheet
		palt()
		copy_to_spritesheet(x1min,y1min,y2,draw_width,14)

    -- draw original area to spritesheet, cause we drew a mask to the screen
    -- the %2 is to get rid of some aliasing
		sspr(x1min%2,0,draw_width,draw_height,x1min,y1min,draw_width,draw_height)

    -- perform some palette swaps
		pal(3,1)
		pal(6,5)
		pal(13,1)

    -- draw original region with mask. remember, black is transparent
    -- because we reset draw state with a call to palt()
		sspr(14+x1min%2,0,draw_width,draw_height,x1min,y1min,draw_width,draw_height)
		pal()
	end
end

function copy_to_spritesheet(x1,y1,y2,width,offset)
	local dy = 0
	for i=y1,y2 do
		memcpy(dy*64+offset/2,0x6000+i*64+x1/2,ceil(width/2)+1)
		dy += 1
	end
end

function draw_player(p)
	pal(2,color_sets[1][p.colors[1]][1])
	pal(8,color_sets[1][p.colors[1]][2])
	pal(15,color_sets[2][p.colors[2]][1])
	pal(5,color_sets[3][p.colors[3]][1])
	pal(4,color_sets[3][p.colors[3]][2])
	pal(12,color_sets[4][p.colors[4]][1])
	
  -- read read_sprite_data function to see what "sprites" is
  -- draw body parts at an angle
	for k,v in pairs(p.sprite_model_sorted) do
		local sp_count = #v.sprites.sprites
		local sp_i = (flr((-camera_angle+1.5+p.angle+v.angle)*sp_count+0.5)%sp_count)+1
		local sprite = v.sprites.sprites[sp_i]
		sspr(sprite[1],sprite[2],v.sprites.width,v.sprites.height,v.pos_scr.x+sprite[3],v.pos_scr.y+sprite[4],v.sprites.width,v.sprites.height,sprite[5],false)
	end
	pal()
end

-->8
-- world

function init_world()
	parse_addr = 0x2000
	parse_nibble_offset = 0
	sprites = {}
	for i=1,8 do
		add(sprites,read_sprite_data())
	end
	anims = {}
	for i=1,11 do
		add(anims,read_anim_data())
	end
	server_data = read_court_data()
	singles_data = read_court_data()
	doubles_data = read_court_data()
	pos_data_cycled = false

	polys = { new_polygon({-46,0,-64,46,0,-64,46,0,64,-46,0,64},3),
	--new_polygon({-46,-8,-64,46,-8,-64,46,0,-64,-46,0,-64},6),
	--new_polygon({46,-8,-64,46,-8,64,46,0,64,46,0,-64},2),
	--new_polygon({46,-8,64,-46,-8,64,-46,0,64,46,0,64},6),
	--new_polygon({-46,-8,64,-46,-8,-64,-46,0,-64,-46,0,64},2)
	}
	
	court_lines = read_line_data()
  --print(#court_lines)
--  for i=1,11 do
--    printh(court_lines[i][1].x, 'lines.log')
--    printh(court_lines[i][1].y, 'lines.log')
--    printh(court_lines[i][1].z, 'lines.log')
--    printh(court_lines[i][2].x, 'lines.log')
--    printh(court_lines[i][2].y, 'lines.log')
--    printh(court_lines[i][2].z, 'lines.log')
--    printh(court_lines[i][3], 'lines.log')
--    printh('', 'lines.log')
--  end
	net = read_line_data()
  print(#net)
  print(net[1][1].x)
  print(net[1][1].y)
  print(net[1][1].z)
  for i=1,#net do
    --print(net[i])
  end
  --stop()

	lines_scr = { draw = draw_lines }
	net_scr = { draw = draw_lines, behind = behind_lines }
	
	chars_index,chars = " -0123456789abcdefghijklmnopqrstuvwxyz,",{}
	local char_data,char_count = {},read_char()
	for i=1,char_count do
		char_data[i] = {}
		for j=1,4 do
			char_data[i][j] = read_char()
		end
		chars[sub(chars_index,i,i)] = char_data[i]
	end
end

function read_sprite_data()
	local s,sprite_count = {
		width = read_nibble(),
		height = read_nibble(),
		sprites = {}
	}, read_char()
	
  -- spx,spy,xoffset,yoffset,flipx,width,height
	for i=1,sprite_count do
		add(s.sprites,{read_char(),read_char(),read_float8(),read_float8(),read_bool()})
	end
	
	return s
end

function read_anim_data()
	local anim,frame_count = { loop = read_bool(), on_finish = read_nibble() }, read_nibble()
	for f=1,frame_count do
		local frame,limb_count = { to_time = read_nibble() },read_nibble()
		for l=1,limb_count do
			add(frame,{read_nibble(),new_vector3d(read_float8(),read_float8(),read_float8()),read_float8(),read_nibble()})
		end
		add(anim,frame)
	end
	return anim
end

-- start
-- end
-- color
function read_line_data(l)
	local count,result = read_char(),{}
	for i=1,count do
		result[i] = {read_v3dchar_div2(),read_v3dchar_div2(),read_nibble()}
	end
	return result
end

function read_court_data()
	local d = {}
	for i=1,2 do
		local s = {}
		for j=1,4 do
			s[j] = {
				start_pos = read_v3dchar(),
				start_angle = read_float8(),
				move_region = {read_char(),read_char(),read_char(),read_char()},
				valid_hit_region = {read_v3dchar(),read_v3dchar()}
			}
		end
		d[i] = s
	end
	return d
end

function draw_lines(l)
	for i=1,#l do
		local v = l[i]
		line(v[1].x,v[1].y,v[2].x,v[2].y,v[3])
	end
end

--[[
interface polygon {
  points_scr : array<...>
  points_3d : array<vector3d>
  col : color
}
--]]

function new_polygon(points,col)
	local p = {
		points_scr = {},
		points_3d  = {},
		col        = col
	}
	
	local p_count = #points - #points%3
	
	for i=1,p_count,3 do
		add(p.points_3d,new_vector3d(points[i],points[i+1],points[i+2]))
	end

	return p
end

function draw_polygon(poly)
	local points = poly.points_scr
	local xl,xr,ymin,ymax = {},{},32761,-32761

	for k,v in pairs(points) do
		local v_next = points[k%#points+1]
		local ys,ye = poly_edge(v,v_next,xl,xr)
		ymin = min(ys,ymin)
		ymax = max(ye,ymax)
	end

	for y=ymin,ymax do
		rectfill(xl[y],y,xr[y],y,poly.col)
	end
end

-- current point, next point, 2 tables
function poly_edge(p1,p2,xl,xr)
	local x1,y1,x2,y2,x_array = p1.x,flr(p1.y),p2.x,flr(p2.y),xr
	
	if y1 > y2 then
		x_array = xl
		local ytemp,xtemp = y1,x1
		y1,y2 = y2,ytemp
		x1,x2 = x2,xtemp
	elseif y1 == y2 then
		if y1 < 0 then
			return 0,0
		elseif y1 > 127 then
			return 127,127
		end
		local xmin,xmax = flr(max(min(x1,x2),0)),flr(min(max(x1,x2),127))
		xl[y1] = not xl[y1] and xmin or min(xl[y1],xmin)
		xr[y1] = not xr[y1] and xmax or max(xr[y1],xmax)
		return y1,y1
	end
	
	local ys,ye,xv,yv = max(y1,0),min(y2,127),x2-x1,y2-y1
	for y=ys,ye do
		x_array[y] = flr(x1+xv*(y-y1)/yv)
	end
	return ys,ye
end
-->8
-- vector & matrix
function new_vector3d(x,y,z)
	return {
		x = x and x or 0,
		y = y and y or 0,
		z = z and z or 0
	}
end

function v3d_add(a,b)
	return new_vector3d(a.x+b.x,a.y+b.y,a.z+b.z)
end

function v3d_sub(a,b)
	return new_vector3d(a.x-b.x,a.y-b.y,a.z-b.z)
end

function v3d_mul(a,b)
	return new_vector3d(a.x*b.x,a.y*b.y,a.z*b.z)
end

function v3d_mul_num(a,b)
	return new_vector3d(a.x*b,a.y*b,a.z*b)
end

function v3d_dot(a,b)
	local d = v3d_mul(a,b)
	return d.x+d.y+d.z
end

function v3d_cross(a,b)
	return new_vector3d(a.y*b.z-a.z*b.y,-(a.x*b.z-a.z*b.x),a.x*b.y-a.y*b.x)
end

function v3d_normal(self)
	local l = sqrt(v3d_dot(self,self))
	if l == 0 then
		return new_vector3d()
	end
	return new_vector3d(self.x/l,self.y/l,self.z/l)
end

function v3d_lerp(a,b,t)
	return new_vector3d(lerp(a.x,b.x,t),lerp(a.y,b.y,t),lerp(a.z,b.z,t))
end

function v3d_length(a)
	local d = v3d_dot(a,a)

	if d >= 0 then
		return sqrt(d)
	end
	
	return 32761
end

-- function v3d_distance(a,b)
	-- return v3d_length(v3d_sub(a,b))
-- end

function v3d_distance2d(a,b)
	return v3d_length(new_vector3d(a.x-b.x,0,a.z-b.z))
end

function orient2d_xy(a,b,c)
	return (a.x-c.x) * (b.y-c.y) - (a.y-c.y) * (b.x-c.x)
end

function orient2d_xz(a,b,c)
	return (a.x-c.x) * (b.z-c.z) - (a.z-c.z) * (b.x-c.x)
end

function matrix_rotate_x(a)
	return {
    {1,0,0},
    {0,sin(a),cos(a)},
    {0,cos(a),-sin(a)},
  }
end

function matrix_rotate_y(a)
	return {
    {cos(a),0,sin(a)},
    {-sin(a),0,cos(a)},
    {0,1,0},
  }
end

-- function matrix_rotate_z(a)
	-- return {{cos(a),-sin(a),0},{0,0,1},{sin(a),cos(0),0}}
-- end

function matrix_mul_add_row(m_row,v)
	return m_row[1]*v.x+m_row[2]*v.y+m_row[3]*v.z
end

function matrix_mul_add(m,v)
	return new_vector3d(matrix_mul_add_row(m[1],v),matrix_mul_add_row(m[2],v),matrix_mul_add_row(m[3],v))
end

function translate_to_view(v)
	local t = matrix_mul_add(mx,matrix_mul_add(my,v3d_add(camera_pos,v)))
	t.z += 192 -- camera fov
	return new_vector3d(round(t.z/camera_distance*t.x+64),round(t.z/camera_distance*t.y+64),t.z)
end
-->8
-- helpers

function table_insert(t,item,index)
	if index < 1 or index > #t then
		add(t,item)
	else
		for i=#t,index,-1 do
			t[i+1] = t[i]
		end
		t[index] = item
	end
end

-- smaller numbers are drawn in front
function get_sort_index(o)
	for i=1,#z_sorted_objects do
		if z_sorted_objects[i]:behind(o) then
			return i
		end
	end
	return 0
end

function behind_point(p1,p2)
	return p2.pos_scr.z <= p1.pos_scr.z
end

function behind_lines(l,p)
	if l[1][1].x < l[1][2].x then
		return orient2d_xy(l[1][1],l[1][2],p.pos_scr) < 0
	end
	return orient2d_xy(l[1][1],l[1][2],p.pos_scr) > 0
end

function lerp(a,b,t)
	return a+(b-a)*t
end

function smooth_lerp(a,b,t)
	return lerp(a,b,t*t*(3-2*t))
end

function point_in_rect(p,r_min,r_max)
	return not (p.x < r_min.x or p.x > r_max.x or p.z < r_min.z or p.z > r_max.z)
end

function round(a)
	return a < 0 and ceil(a-0.5) or flr(a+0.5)
end

function read_float8()
	return read_char()/16
end

function read_char()
	local val = bor(shl(read_nibble(),4),read_nibble())
	if val >= 0x80 then
		val -= 256
	end
	return val
end

function read_v3dchar()
	return new_vector3d(read_char(),read_char(),read_char())
end

function read_v3dchar_div2()
	return new_vector3d(read_char()/2,read_char()/2,read_char()/2)
end

function read_bool()
	return read_nibble() ~= 0
end

function read_nibble()
	local val = peek(parse_addr+flr(parse_nibble_offset/2))
	if parse_nibble_offset%2 == 1 then
		val = band(val,0x0f)
	else
		val = shr(band(val,0xf0),4)
	end
	parse_nibble_offset += 1
	return val
end

__gfx__
77777777777777777777777777770000111111111111111111111111111111111110000011111111111111111111111111111111111111111111110011110000
00000000000000000000000000070000177666c177666c177666c176117617617610000017617766666c177666c177666c177666c177666c1776c11017610000
0770707007007700070070707707000017ccccc17ccccc17ccccc17c117c1cc17c10000017c17ccccccc17ccccc17ccccc17ccccc17ccccc17cccc1117c11111
0700707070707070707070707007000017c156c17c156c17c155517c116c15517c10000017c17c16c16c17c156c17c156c17c156c17c155517c1ccc117c577c1
0070777077707070707077700707000016c117c16c57c116c111116c117c17616c10000016c16c17c16c16c116c16c116c16c117c16c677616c15cc116c16cc1
0770707070707700070077707707000016c567c16c16cc16c117616c567c17c16c10000016c16c17c17c16c117c16c116c16c57c11cccccc16c116c116c156c1
0000000000000000000000000007000016c1ccc16c156c16c117c16c1ccc17c16c11111117c16c16c17c16c117c16c117c16c16cc155556c16c117c116c117c1
7777777777777777777777777777000016c156c16c677c16c677c16c156c16c16c67617667c16c16c16c16c116c16c677c16c156c176677c16c677c116c677c1
28599ade2ddcc70000000000000000001cc11cc1cccccc1cccccc1cc11cc1cc1ccccc1ccccc1cc1cc1cc1cc11cc1cccccc1cc11cc1cccccc1cccccc11cccccc1
f4000000000000000000000000000000155115515555551555555155115515515555515555515515515515511551555555155115515555551555555115555551
010554899ade67000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
0543cd1000000000000000000000000017611761000000011111110177666c117761761176176176176176117c1761176177766c177666c1177666c177766c10
2000000000000002000000000000000017c117c1000000116c16c1117ccccc11ccc17c117c17c17c17c17c117c17c117c16ccccc17ccccc117ccccc1cccccc10
0111111111111110000000000000000017c116c10000001677c76c117c156c1156c17c117c17c17c17c16c116c17c116c15556cc17c1555117c1555155556c10
0111111111111110000000000000000016c117c10111111676c6cc116c116c1116c16c116c16c16c16c11657c116c667c1116cc516c5761116c1111117656c10
2000000000000002000000000001111116c57c110176c11c6ccccc116c117c1017c16c116c16c16c16c17c16cc1cccccc117cc5116c1cc1016c100001cc16c10
2000000000000002000000000001776116c16cc1016cc115c6ccc5116c117c1017c16c117c16c17c17c17c156c155556c17cc11116c1551116c1111115517c10
07999111111111100000000000016cc116c156c1015551115ccc51116c657c1016c16c677c16c67c67c16c117c176677c16cc67616c6776116c6776176677c10
0888811111111110000000000001ccc11cc11cc10111110115c51101ccc16c101cc1cccccc1cccccccc1cc11cc1cccccc1cccccc1cccccc11cccccc1cccccc10
200000000000000200000000000156c11551155100000000115110015551cc101551555555155555555155115515555551555555155555511555555155555510
20000000000000020000000000011551111111110000000001110001111155101111111111111111111111111111111111111111111111111111111111111111
07aaaaaa11111110000000000000111100000000000000000010000000011110177766c177766c177766c177666c177666c1761176177666c177666c17611761
099999991111111000000000000000000000000000000000000000000000000016ccccc1cccccc1cccccc17ccccc17ccccc17c117c17ccccc17ccccc17c117c1
20000000000000020000000000000000000000000000000000000000000000001556c15155556c155556c16c116c17c155517c117c17c156c17c156c17c117c1
20000000000000020000000000000000000000000000000000000000000000001116c11111116c176677c15657c116c111116c116c16c117c16c116c16c117c1
07eeeeeeeee111100000000000000000000000000000000000000000000000000017c10000017c17ccccc17c16cc16c576116c656c16c567c16c657c16c117c1
0dddddddddd111100000000000000000000000000000000000000000000000000017c10000017c16c155517c156c16c1cc11ccc16c16c1ccc1ccc17c16c17cc1
20000000000000020000000000000000000000000000000000000000000000000016c10000016c16c677616c677c16c1551155516c16c1555155516c16c6cc51
2000000000000002000000000000000000000000000000000000000000000000001cc1000001cc1cccccc1cccccc1cc111111111cc1cc111111111cc1cccc511
07777777777777600000000000000000000000000000000000000000000000000015510000015515555551555555155100000001551551000000015515555110
076cccccccccccc00000000000000000000000000000000000000000000000000011110000011111111111111111111100000001111111000000011111111100
20000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04455500044555000445550004455500044555000445550004455500044555000445550004455500044555000445550004455500044555000445550004455500
44445550444455504444555044445550444455504444555044445550444455504444555044445550444455504444555044445550444455504444555044445550
44445550444455504444555044445550444455504444555044445550444455504444555044445550444455504444555044445550444455504444555044445550
467f7650f467f7604f467f7044f467f0444f56704444f56044445f50444455f044445550f44455504f44555064f45550764f5550f764f5507f765f5067f765f0
f7cfc7f05f7cfc7004f7cfc0044f7cf00445f7c004455f70044555f0044555505445555054455500f44555007f455500c7f55500fc7f5500cfc7f5007cfc7f50
0fffff000ffffff008fffff008fffff0028ffff00288fff002288ff0022288f008222800f8822200ff882200fff88200ffff8200fffff200fffff200ffffff00
28222820028228000288220002282200082282000882280008882220088882202888882022888800222888000822880002822800022822000228820008228200
28888820028888200228888002228800082228000882220008882220088882202888882022888800222888000222880008222800088222008888220028888200
68888860068888600628886006228700072227000782260007882260068882606888886062888600622887000622870007222700078226006888260068888600
86777680086777800866778008667800086668000876680008776680087776808677768086777800866778000866780008666800087668008776680087776800
88888880088888800888888008888800088888000888880008888880088888808888888088888800888888000888880008888800088888008888880088888800
08800880088008800880088008800880ff077f00aa900aa900aa900aa900aa900000000000000000000000000000000000000000000000000000000000000000
08800880088008800880088708860880ffaaaa9a77797aaafaaaa9aaaa9aaaa90000000000000000000000000000000000000000000000000000000000000000
0ff00ff00ff00ff60ff70ff60ff60ff000aaaa9aaaa9a77797aaafaaaa9aaaa90000000000000000000000000000000000000000000000000000000000000000
07700676067706770666066006600660009aa999aa999aa99977f9faa9f9aa990000000000000000000000000000000000000000000000000000000000000000
0660006600660000000000000000000000099900999009990099900fff0099900000000000000000000000000000000000000000000000000000000000000000
06776000067770000067760000077600000676000000670000000670000000770000000000000000000000000000000000000000000000000000000000000000
67060700670607000670670000706760000767600000767000000776000000770000000000000000000000000000000000000000000000000000000000000000
70606070676060700676067000760670000706700000707000000776000000777600000076000000670000006760000006770000067760000077760000777700
76060670670606700670607000706070000660700000767600000677000000776760000067700000767000007676000067607000676676000706076007060670
07606076067060760067067600076676000067760000677600000677000000770676000007770000676700007607600067666600676067000760667007606070
00067777000667770000677700006777000006770000067700000067000000660067600006776000067760006760700066706700667607000676067007060670
00000066000000660000006600000066000000660000006600000066000000660006760000677000006770000677760006677600066776000667770006777760
00000000000000000000000000000000000000000000000000000000000000000000670000007600000676000006760000667000006670000066760000667600
0aa90000011100000000000000011111100000000000000000000000000000000007700000077000000770000067760000677600006776000067760000677600
7aaaf000111110000000000001111111111000000000000000000000000000000007700000076000006707000076070000760700067607600676076006760760
a77f9000111110000000000011111111111100000000000000000000000000000007700000676600006767000076670006706760067066700770607007606070
9aa99000011100000000000011111111111100000000000000000000000000000007700000676600006707000076070006760760067606700776067007060670
09990000000000000000000011111111111100000000000000000000000000000007700000676600006767000076670006706760067067600670676007606070
00000000000000000000000001111111111000000000000000000000000000000007700000077000006766000066760000667600007607000076070006760760
00000000000000000000000000011111100000000000000000000000000000000007700000077000000770000007700000677600006776000067760000677600
00000000000000000000000000000000000000000000000000000000000000000006600000066000000670000006700000067000000670000006700000067000
00000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000097600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000166555111111111111111111111111111a777e0000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000016511111111111111111111111111111111b7f00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001511117777177771177711777711111777711c110000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000151111771771177117711177177111117117111111000000000000000000000000000000000000000000000000000000
00111111111111111111111111111111111111777771177117711177177177177777111111111111111111111111111111110000000000000000000000000000
01777777777777676666c6ccccccccccccc551771111177117711177177111177117155ccccc6c6666767777777776766c6c1000000000000000000000000000
01766ccccccccccccccccccccccccccccccc5177155177771777717777155517777715cccccccccccccccccccccccccccccc1000000000000000000000000000
176cccccccccccccccccccccccccccccccccc5115cc51111511115111155cc5111115cccccccccccccccccccccccccccccccc100000000000000000000000000
17ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc100000000000000000000000000
11111111116cccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000
01111111116cccc51111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
0011111116ccccc51111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000
0001111117cccc555117777777776766111117777777776766111117777777776766111117776611111777777776761111100000000000000000000000000000
0000000017cccc555117cccccccccccc5111176ccccccccccc1111176ccccccccccc1111576ccc11111766cccccccc1000000000000000000000000000000000
000000017ccccc551176ccccccccccc5511117cccccccccccc111117cccccccccccc1111557cccc111576cccccccccc100000000000000000000000000000000
000000017cccc555117cccccccccccc5551117cccccccccccc111117cccccccccccc1115556cccc111557cccccccccc100000000000000000000000000000000
000000017cccc555116cccc111111115551166ccc1111ccccc111116cccc1111ccccc1155511111115556cccc111111100000000000000000000000000000000
000000176cccc55116ccccc51111111151116cccc11116cccc111116cccc11116cccc1115117776615556cccc111111000000000000000000000000000000000
00000017cccc555116ccccc17761111151116cccc51116cccc111116cccc11156cccc11151176ccc115556cccc11110000000000000000000000000000000000
00000017cccc555117cccc176cc5111111116cccc51117cccc111116cccc11156cccc1111156cccc115556cccc11111111000000000000000000000000000000
00000176cccc551176cccc16ccc5111111166ccc551116cccc111116cccc111556cccc111556ccccc15556ccccccccccc1000000000000000000000000000000
0000017cccc555117ccccc51111551111116cccc551117cccc111116cccc111557cccc1115556cccc115556ccccccccccc100000000000000000000000000000
0000017cccc555117cccc555111151111117cccc551117cccc111117cccc111557cccc1115557cccc115556ccccccccccc100000000000000000000000000000
000017ccccc551176cccc555511111111117cccc551117cccc111117cccc1115576ccc1115557ccccc1555ccccccccccccc10000000000000000000000000000
000017cccc555117ccccccc6c66676777776ccc5551117cccc677777cccc1115557cccc677777ccccc115511111111ccccc10000000000000000000000000000
000016cccc555116ccccccccccccccccccccccc5511117cccccccccccccc1111557ccccccccccccccc1151111111156ccccc1000000000000000000000000000
00016ccccc55116cccccccccccccccccccccccc5511116cccccccccccccc1111556cccccccccccccccc1111111115556cccc1000000000000000000000000000
00016cccc55511ccccccccccccccccccccccccc551111ccccccccccccccc111155ccccccccccccccccc1111111155556ccccc100000000000000000000000000
0001ccccc5551111111111111111111111111115511111111111111111111111551111111111111111111111111155557cccc100000000000000000000000000
0001111115511111111111111111111111111111511111111111111111111111511111111111111111111111111155557ccccc10000000000000000000000000
00111111115111111111111111111111111111111111111111111111111111111111111111111111111111111111155557cccc10000000000000000000000000
017777777777777676666c6cccccccccccccccccccc6c66667677777777777777676666c6ccccccccc6c66667677777777ccccc1000000000000000000000000
01766cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1000000000000000000000000
176ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc100000000000000000000000
17cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc100000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000
00111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000
00001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000
77777700077777777707000777777700070007777770707000777770070077070777777700000000000000b30000000000000000000000000000000000000000
777777070777777777070077777777707707077777707070707777070707070707707770000000000000676b3000000000000000000000000000000000000000
77777707077777777707770777777777070707777770007070777700070707070770070000000000000071767600000000000000000000000000000000000000
77777700077777777707007777777700770007777777707000777707070007007770777000000000000067671700000000000000000000000000000000000000
7777777777777777777777777777777777777777777777777777777777777777777777770000000000000bb67600000000000000000000000000000000000000
7777000000000000000000000007000000000000000000000000000000000000000000000000000000b30b113000000000000000000000000000000000000000
56557000000000000000000700070000000000000000000000000000000000000000000000000000003b3b2230b3000000000000000000000000000000000000
0706767606767606760676060677000000000000000000000000000000000000000000000000000000033bbb3333000000000000000000000000000000000000
0777675707575707570757070757000000000000000000000000000000000000000000000000000000000b333330000000000000000000000000000000000000
0755067777067777070676070677700000000000000000000000000000000000000000007777000000000bb33000000000070000000000000000000000000000
0500055555055555050555050555500000000000000000000000000000000000000000005655700000000bb33000000700070000000000000000000000000000
00000770000000007000000000000000000000000000000000000000000000000000000007067676067676367606760606770000000000000000000000000000
00007550676067007707070676000000000000000000000000000000000000000000000007776757075757375707570707570000000000000000000000000000
00007000757075007507070755000000000000000000000000000000000000000000000007550677770677770706760706777000000000000000000000000000
00007000677767706706770567000000000000000000000000000000000000000000000005000555550555550505550505555000000000000000000000000000
00005777555555505505556776000000000000000000000000000000000000000000000000000770000000007000000000000000000000000000000000000000
00000555000000000000005555000000000000000000000000000000000000000000000000007550676067007707070676000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000007000757075007507070755000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000007000677767706706770567000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005777555555505505556776000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000555000000000000005555000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111177777777777777711111111111111111111111111111111000000000000000000000000
111111111111111111111111111111111111111111111111111111111777707070007777111111111111111111111111111111110000aa0aaa0a0a00000aa000
11111111111111111111111111111111111111111111111111111111177770707070777711111111111111111111111111111111000a000a0a0a0a000000a000
11111111111111111111111111111111111111111111111111111111177770007070777711111111111111111111111111111111000a000aaa0a0a000000a000
11111111111111111111111111111111111111111111111111111111177777707000777711111111111111111111111111111111000a000a000a0a000000a000
111111111111111111111111111111111111111111111111111111111777777777777777111111111111111111111111111111110000aa0a0000aa00000aaa00
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111107aaaaaa1111111011
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111099999991111111011
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111133333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333311111111
11111111333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333311111111
11111111333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333311111111
11111113333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333331111111
11111113333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333331111111
11111113333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333331111111
11111133333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333111111
11111133333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333111111
11111133333333333333333336666666666666666666666611000666666666666666666666666666666666666666666666666666333333333333333333111111
11111333333333333333333336333333333633333333333111100033333333336333333333333333333333333333363333333336333333333333333333311111
11111333333333333333333336333333333633333333333111100033333333336333333333333333333333333333363333333336333333333333333333311111
11111333333333333333333363333333333633333333333114167436773333333333333333333333333333333333363333333333633333333333333333311111
11113333333333333333333363333333336333333333333311471467637333333333333333333333333333333333336333333333633333333333333333331111
111133333333333333333333633333333363333333333333a4444476367333333333333333333333333333333333336333333333633333333333333333331111
11113333333333333333333363333333336333333333333399a99473637333333333333333333333333333333333336333333333633333333333333333331111
111333333333333333333333633333333363333333333333999aa676673333333333333333333333333333333333336333333333633333333333333333333111
111333333333333333333336333333333363333333333333699a4777633333333333333333333333333333333333336333333333363333333333333333333111
111333333333333333333336333333333363333333333333a6674663333333333333333333333333333333333333336333333333363333333333333333333111
113333333333333333333336333333333633333333333333aaaaaa33333333333333333333333333333333333333333633333333363333333333333333333311
113333333333333333333336333333333633333333333331aa11aa33333333333333333333333333333333333333333633333333363333333333333333333311
11333333333333333333336333333333363333333333311144114413333333333333333333333333333333333333333633333333336333333333333333333311
13333333333333333333336333333333363333333333111776116771333333333333333333333333333333333333333633333333336333333333333333333331
13333333333333333333336333333333363333333333111661111661333333a79333333333333333333333333333333633333333336333333333333333333331
13333333333333333333336333333333366666666666555555555555666667a77f66666666666666666666666666666633333333336333333333333333333331
3333333333333333333333633333333363333333333331111111111333333aaaf933333333333333333333333333333363333333336333333333333333333333
333333333333333333333633333333336333333333333331111113333333aaaa9933333333333333333333333333333363333333333633333333333333333333
33333333333333333333363333333333633333333333333333333333333aaa999333333333333333333333333333333363333333333633333333333333333333
3333333333333333333336333333333363333333333333333333333333aaaa336333333333333333333333333333333363333333333633333333333333333333
3333333333333333333336333333333363333333333333333333333333aaa3336333333333333333333333333333333363333333333633333333333333333333
333333333333333333333633333333336333333333333333333333333aaa33336333333333333333333333333333333363333333333633333333333333333333
33333333333333333333633333333333633333333333333333333333aaa333336333333333333333333333333333333363333333333363333333333333333333
3333333333333333333363333333333633333333333333333333333a9a3333336333333333333333333333333333333336333333333363333333333333333333
33333333333333333333633333333336333333333333333333333339993333336333333333333333333333333333333336333333333363333333333333333333
33333333333333333333633333333336333333333333333333333399933333336333333333333333333333333333333336333333333363333333333333333333
33333333333333333336333333333336333333333333333333333999333333336333333333333333333333333333333336333333333336333333333333333333
33333333333777777777777777777777777777777777777777777997777777777777777777777777777777777777777777777777777777777777773333333333
33333333333033533356353353335335335333533533533533359953353335335335333533533533353353353353335335335333533536533353303333333333
33333333333055555555555555555555555555555555555555559555555555555555555555555555555555555555555555555555555555555555503333333333
33333333333033533356353353335365335333533533533533359353353335115135333533533533353353353353335335635333533536533353303333333333
33333333333305555555555555555555555555555555555555595555555555555555555555555555555555555555555555555555555555555555503333333333
33333333333303353353335335335365333533533533533353393353353335115335333533533533533353353353353335635335335333533533033333333333
33333333333305555555555555555555555555555555555555955555555555555555555555555555555555555555555555555555555555555555033333333333
33333333333303353353335335335365333533533533533353953353353335335335333533533533533353353353353335635335335333533533033333333333
33333333333305555555555555555555555555555555555559555555555555555555555555555555555555555555555555555555555555555555033333333333
33333333333333333633333333333633333333333333333339333333333333336333333333333333333333333333333333363333333333363333333333333333
33333333333333333633333333333633333333333333333383333333333333336333333333333333333333333333333333363333333333363333333333333333
33333333333333333633333333333633333333333333333383333333333333336333333333333333333333333333333333363333333333363333333333333333
33333333333333333633333333333633333333333333333833333333333333336333333333333333333333333333333333363333333333363333333333333333
33333333333333336333333333333633333333333333333833333333333333336333333333333333333333333333333333363333333333336333333333333333
33333333333333336333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333336333333333333333
33333333333333336333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333336333333333333333
33333333333333336333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333336333333333333333
33333333333333336333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333336333333333333333
33333333333333363333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333333633333333333333
33333333333333363333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333333633333333333333
33333333333333363333333333336333333333333333333333333333333333336333333333333333333333333333333333336333333333333633333333333333
33333333333333363333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333633333333333333
33333333333333363333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333633333333333333
33333333333333633333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333363333333333333
33333333333333633333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333363333333333333
33333333333333633333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333363333333333333
33333333333333633333333333363333333333333333333333333333333333336333333333333333333333333333333333333633333333333363333333333333
33333333333336333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333336333333333333
33333333333336333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333336333333333333
33333333333336333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333336333333333333
33333333333336333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333336333333333333
33333333333336333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333336333333333333
33333333333363333333333333633333333333333333333333333333333333336333333333333333333333333333333333333363333333333333633333333333
33333333333363333333333336666666666666666666666666666666666666666666666666666666666666666666666666666666333333333333633333333333
33333333333363333333333336333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333633333333333
33333333333363333333333336333333333333333445553333333333333333333333333333333333333333333333333333333336333333333333633333333333
33333333333363333333333336333333333333334444555336773333333333333333333333333333333333333333333333333336333333333333633333333333
33333333333633333333333336333333333333334444555367637333333333333333333333333333333333333333333333333336333333333333363333333333
3333333333363333333333333633333333333333f444555376367333333333333333333333333333333333333333333333333336333333333333363333333333
33333333333633333333333336333333333333335445553373637333333333333333333333333333333333333333333333333336333333333333363333333333
3333333333363333333333336333333333333333fccdddf676673333333333333333333333333333333333333333333333333333633333333333363333333333
3333333333633333333333336333333333333333ddccccf777633333333333333333333333333333333333333333333333333333633333333333336333333333
33333333336333333333333363333333333333ffddcccc3663333333333333333333333333333333333333333333333333333333633333333333336333333333
33333333336333333333333363333333333333ff6dccc63333333333333333333333333333333333333333333333333333333333633333333333336333333333
3333333333633333333333336333333333333333c6777c3333333333333333333333333333333333333333333333333333333333633333333333336333333333
3333333333633333333333336333333333333333cccccc3333333333333333333333333333333333333333333333333333333333633333333333336333333333
33333333363333333333333633333333333333331cc1ff3333333333333333333333333333333333333333333333333333333333363333333333333633333333
33333333363333333333333633333333333333117ff1661133333333333333333333333333333333333333333333333333333333363333333333333633333333
33333333363333333333333633333333333331116661111113333333333333333333333333333333333333333333333333333333363333333333333633333333
33333333363333333333333633333333333331111111111113333333333333333333333333333333333333333333333333333333363333333333333633333333
33333333363333333333333633333333333331111111111113333333333333333333333333333333333333333333333333333333363333333333333633333333
33333333633333333333333633333333333333111111111133333333333333333333333333333333333333333333333333333333363333333333333363333333
33333333633333333333336333333333333333331111113333333333333333333333333333333333333333333333333333333333336333333333333363333333
33333333633333333333336333333333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333363333333
33333333633333333333336333333333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333363333333
33333336333333333333336333333333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333336333333
33333336333333333333336333333333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333336333333
33333336333333333333336333333333333333333333333333333333333333333333333333333333333333333333333333333333336333333333333336333333
33333336333333333333363333333333333333333333333333333333333333336333333333333333333333333333333333333333333633333333333336333333
33333336333333333333363333333333333333333333333333333333333333336333333333333333333333333333333333333333333633333333333336333333
33333363333333333333363333333333333333333333333333333333333333336333333333333333333333333333333333333333333633333333333333633333
33333363333333333333363333333333333333333333333333333333333333336333333333333333333333333333333333333333333633333333333333633333
33333366666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666633333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33300000000000000333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33011111111111111033333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33011111111111111033333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00000000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00000000000000000000000000000000000033333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00ccc0c000ccc0c0c0ccc0ccc00000cc000033333333333333333333377777777777777733333333333333333333333333333333333333333333333333333333
00c0c0c000c0c0c0c0c000c0c000000c000033333333333333333333377770007000777733333333333333333333333333333333333333333333333333333333
00ccc0c000ccc0ccc0cc00cc0000000c000033333333333333333333377777077070777733333333333333333333333333333333333333333333333333333333
00c000c000c0c000c0c000c0c000000c000033333333333333333333377777707070777733333333333333333333333333333333333333333333333333333333
00c000ccc0c0c0ccc0ccc0c0c00000ccc00033333333333333333333377770077000777733333333333333333333333333333333333333333333333333333333
00000000000000000000000000000000000033333333333333333333377777777777777733333333333333333333333333333333333333333333333333333333

__map__
c7011838a0c007b100020d08800820d08801020d08801820d08802020d08802820d08803020d08803820d08804020d08804820d08805020d08805820d08806020d08806820d08807020d08807820d0880871c003090b00083090b00103090b00183090b00203090b00283090b00303090b00383090b00383000b01303000b012
83000b01203000b01183000b01103000b01083000b01103000b01183000b01203000b01283000b01303000b01383000b01383090b00303090b00283090b00203090b00183090b00103090b00083090b00450e002bf0e00042bf0e00082bf0e000c2bf0e00102bf0e00142bf0e00182bf0e001c2bf0e00182be0e01142be0e011
02be0e010c2be0e01082be0e01042be0e012201202b000002201202bf0000881c4038c09004838c09005038c09005838c09006038c09006838c09007038c09007838c09007838d09017038d09016838d09016038d09015838d09015038d09014838d09015038d09015838d09016038d09016838d09017038d09017838d090178
38c09007038c09006838c09006038c09005838c09005038c09004838c0900851c4033b0c004833b0c005033b0c005833b0c006033b0c006833b0c007033b0c007833b0c007833e0c017033e0c016833e0c016033e0c015833e0c015033e0c014833e0c015033e0c015833e0c016033e0c016833e0c017033e0c017833e0c0178
33b0c007033b0c006833b0c006033b0c005833b0c005033b0c004833b0c00001523f000000244100000fe4104323f0e8000044100000004623f000f00044100010004923f00000004410e800004c23f0001000441000f0004104323f800000044080000004623ece8000044140000004923e000000244200000fe4c23ec00000
04414e800004104323f0001000441000f0004623f00000004410e800004923f000f00044100010004c23f0e8000044100000004104323ec0000004414e800004623e000000244200000fe4923ece8000044140000004c23f800000044080000004001a4100d000002628c0f0006228c0e80135d8c0f0005001a41fcd0000326e
0c0e00062d8c0e00935e0c018005064341fcd000fe2620c008006220c010ff35e0c0d800554100d000012628c0f0006228c0e80035d8c0f000574104d000022618c0e0006218c0d80135d8c02800594102d000032610c0d8006210c0d00635d8c028005064341fcd0000326e0c0e00062d8c0e00835e0c018005541fed000022
6e0c0d80062e8c0d00535d8c00800574100d000012600c0e8006208c0d80235e0c0e800594100d000002618c0f0006218c0e00135e8c0d8005001a4100d000002628b000006220a0000475d8c0f0005064341fcd000fe2620b0f0006220b0e80475e0c0d800554100d000012620c0d8006220b8d00485d8c0f000574104d0000
22628c0e0006228c0d80285d8c02800594102d000032610c0d8006228c0180135d8c0280050800380000371638ea00e8000000f1002200de06223ce200d01e0000f8003800ea3700380000e81600000f002200de06223ce200d01e0000f800c808eac800c90000091600180f00de08dec422fae200001e00300800c80800c816
c9ea0000000018f100de08dec422fae200001e00300a003200de06223cea00d0160000f1002200de06223cea00d0160000f6003200de06223cea00d01600000f002200de06223cea00d0160000f600ce08dec422faea00001600300f00de08dec422faea00001600300a00ce08dec422faea0000160030f100de08dec422faea
00001600300a003200de06223ce200d01e0000f1002200de06223ce200d01e0000f6003200de06223ce200d01e00000f002200de06223ce200d01e0000f600ce08dec422fae200001e00300f00de08dec422fae200001e00300a00ce08dec422fae200001e0030f100de08dec422fae200001e00300bc400a03c00a063c00a03
c006063c0060c400606c40060c400a06d600d02a00d06d600302a003060000d000003060000a10000a6600005f00005a6d400a1d4005f62c00a12c005f626c100003f00005c1fd003ffd005c1fa003ffa005c1f7003ff7005c4f500c4ff005c8f500c8ff005ccf500ccff005d0f500d0ff005d4f500d4ff005d8f500d8ff005d
cf500dcff005e0f500e0ff005e4f500e4ff005e8f500e8ff005ecf500ecff005f0f500f0ff005f4f500f4ff005f8f500f8ff005fcf500fcff00500f50000ff00504f50004ff00508f50008ff0050cf5000cff00510f50010ff00514f50014ff00518f50018ff0051cf5001cff00520f50020ff00524f50024ff00528f50028ff
0052cf5002cff00530f50030ff00534f50034ff00538f50038ff0053cf5003cff005c0f400c00000040f4004000000c0f40040f4007272015050b290b050b5b00080b3f0a050b4e14080b770a080b6314080b6900080b7800080b4714080b5514080b7114080b2000080b2700080b700a080b7000080b680a080b5c14080b2e0
0080b3500080b3c00040b4500070b200a080b3f00070b4b000a0b5400080b5b00080b6a14080b370a080c6200080b6900080b4014080b430a080b7814080b4a0a0a0b3f0a080b5a0a080b070a080b1b0a050c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000126141b6211f6211e6311b63116621126210e6110a6110861105611026150160101601016010160101601206001f6001c6001b6001a60019600176001560000000136001260000000000000000000000
0001000002714192250d7141171115711197050100500000000000000000000000000000000000000000000000000000000000000000000000000000000125000000000000000000000000000000000000000000
00010000026110361106621086212007423065167311272112721147150d6000301003010020101e6002060022600206001260000000000000000000000000000000000000000000000000000000000000000000
0001000004611086110b6210e62119074230651973119721187211771500000040100401001010010100101000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000046110a6110f621106211d074220651773116721167211671504600000000101001010030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000b7140e711117211472117031190411b5251c0012c6050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000001063120710107324070010432b06001333230311c13104531173210a521131210c521103210a5210d121075110b31104511091110251107311015110511107511031110c51102111105150000000000
010400003005030041300313002137050370413704137031370313702137021370113701137011370113701500000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001f0501f0521f0421f0321f0221f01218050180101805018052180521804218032180221f0501f04022050220502205022050210512105021050210501f0501f0501d0511d0521d0521d0521f0501f050
000a00001f0421f0321f0221f012000000000018000180001800018002180021800218002180021800218002180021800200000000000000000000000000000000000000001a0541a0501d0511d0501f0511f050
000a00002105021052210422103221022210121a0501a0201a0501a0521a0421a0321a0221a012210502105022050220502205022050210512105021050210501f0501f0501d0511d0521d0521d0521f0501f050
000a00001f0521f0521f0521f0521f0421f0321f0221f01200000000000000000000000000000000000000001a0501a0501a0501a0501d0501d0501d0501d0502205022050220502205021050210502105021050
010a00000c07300000000000000024655000000c073246050c07300000000000000024655000000c073000000c073000000c0730000024655000000c0730000000000000000c0730000024655000000c07300000
010a0000001500015000000000000015000150000000000007150071500015000150000000000000150000000015000150000000000000150001500a1500a1500000000000091500915005150051500000000000
010a00000015000150000000000000150001500000000000071500715000150001500000000000001500000000150001500000000000001500000000150001500a1500a150091500000005150051500215000000
010a0000021500215000000000000215002150000000000009150091500215002150000000000002150000000a150000000a1500000009150091500a1500a1500000000000091500915005150051500000000000
010a00000015000150000000000000150001500000000000071500715000150001500000000000001500000000150001500000000000001500000000150000000a1500a150091500915005150051500000000000
010a0000105501055010550105500c5500c5500c5500c5501355013550135501355010550105501055010550115501155011550115500c5500c5500c5500c550115501155011550115500c5500c5500c5500c550
010a0000105501055010550105500c5500c5500c5500c55013550135501355013550105501055010550105500c5500c5500c550000000c550000000c550000001155011550135501355015550155501655016550
010a0000115501155011550115500e5500e5500e5500e55015550155501555015550115501155011550115500c5500c5500c5500c5501155011550115501155013550135500c55011550155500c5501055013550
010a0000135501355013550135500c5500c5500c5500c550135501355013550135500c5500000009550095500e5500e550165501655015550155501155011550165501655013550135500c5500c5501155011550
010a00000c07300000000000000024655000000c073246050c0730000024655000000c073000000c0730000024655000000c073000000c07300000246552465524655000000c0730c07324655000002465500000
010a00002475024751247412474124731247212775027750277412773124750247502474124731247212473129750297502975029750277502775027750277502675126750247512475022750227502275022750
010a00002675026750267502675126741267352475024750247502474124741247412473124731247212472124711247150000000000187301d73021720187201d73021735187251d72522730227252473024725
010a0000247502475024741247412473124721297502974129731297212475024741247412473124731247212b7542b7502b7502b750297502975029750297502775027750267502675022750227502275022750
010a00002475024751247412474124731247312472124721247112471500000000000000000000000000000029730297202973029720277302772027730277202673026720267302672022730227202273022720
010a0000021500215000000000000215002150091500915000000000000915009150051500515000000000000a1500000009150091500a1500a15000000000000a1500a150051500000005150051500000000000
010a00000c5500c5500c5500c550135501355013550135500c5500c550135501355013550135500c5500c550115501155011550115500f5500f5500f5500f5501a5501a550185501855016550165501655016550
010a00000e5500e5500e5500e5501555015550155501555011550115501555015550155501555015550155501655016550165501655015550155501555015550115501155011550115500c5500c5500c5500c550
010a00000c5500c5500c5500c550115501155011550115500c5500c550115501155011550115500c5500c55013550135501355013550115501155011550115501b5501b5501a5501a55016550165501355013550
010a00000c07300000000000000024655000000c0732460524655000000c0730000000000000000c073000002465500000000000000024655000000c073000000c07300000246552465524655000000c0730c073
__music__
01 080c0d11
00 090c0e12
00 0a0c0f13
00 0b151014
00 080c0d11
00 09150e12
00 0a0c0f13
00 0b151014
00 161e0d1b
00 17151a1c
00 181e0e1d
02 1915101b

