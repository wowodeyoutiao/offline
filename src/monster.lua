local actor = require "actor"
local drop_loot = require "drop_loot"
local monster_conf = require "monster_conf"
local game_utils = require "game_utils"

local monster =  {}
monster.__index = monster
setmetatable(monster, actor)

function monster.new(id)
	local t  =  actor.new()
	setmetatable(t, monster)
	if id then 
		if not monster_conf[id] then return nil end
		game_utils.copy_attri(t.attri, monster_conf[id]) 
	end
	return t
end

function monster:set_default_attri(id)
	if not self.level then return end
	game_utils.copy_attri(self.attri, monster_conf[id])
	self.hp = self.hp * self.level
end

return monster



