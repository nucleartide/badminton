
-- Lua Library Imports
state={}
state.player_one_serve=0
state.player_two_serve=1
state.rally=2
state.post_rally=3
state.player_one_win=4
state.player_two_win=5
function game()
    return {state = state.player_one_serve,update = game_update,draw = game_draw}
end
function game_update(g)
end
function game_draw(g)
end
function player(g)
    return {game = g,update = player_update,draw = player_draw}
end
function player_update(p)
end
function player_draw(p)
end
local actors = nil

function _init()
    local g = game()

    local p1 = player(g)

    local p2 = player(g)

    actors = {}
    add(actors,g)
    add(actors,p1)
    add(actors,p2)
end
function _update60()
end
function _draw()
end
