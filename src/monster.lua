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
	if id then game_utils.copy_attri(t, monster_conf[id]) end
	return t
end

function monster:set_default_attri()
	if not self.level then return end
	game_utils.copy_attri(self, monster_conf['default_monster1'])
	self.hp = self.hp * self.level

end

local mon1 = monster.new()
mon1.level = 3
mon1:set_default_attri()
print(mon1.hp)
print(mon1.name)



