local actor = require "actor"
local drop_loot = require "drop_loot"
local monster_conf = require "monster_conf"
local game_utils = require "game_utils"

local monster =  {}
monster.__index = monster
setmetatable(monster, actor)

function monster.new(id)
	local t  =  actor.new()
	game_utils.copy_attri(t, monster_conf[id])
	setmetatable(t, monster)
	return t
end

local mon1 = monster.new('monster1')
print(mon1.hp)
print(mon1.physicaldamage)



