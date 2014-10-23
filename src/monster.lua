local actor = require "actor"
local drop_loot = require "drop_loot"
local item = require "item"
local monster_conf = require "monster_conf"
local game_utils = require "game_utils"
local logger = require "logger"

local monster =  {}
monster.__index = monster
setmetatable(monster, actor)

function monster.new(id)
	local t  =  actor.new()
	setmetatable(t, monster)
	if id then 
		local mon = monster_conf[id]
		if not mon then return nil end
		game_utils.copy_attri(t.attri, mon) 
		t.drop = mon.drop
	end
	return t
end

function monster:set_default_attri(id)
	if not self.level then return end
	game_utils.copy_attri(self.attri, monster_conf[id])
	self.hp = self.hp * self.level
end

function monster:get_drop()
	local loot = self.drop
	if loot then
		local goods = drop_loot["get_"..loot]()
		if goods then
			local t = {}
			for _,v in ipairs(goods) do
				local it = item.new(v)
				if it then
					table.insert(t, it)
				else
					logger.log("do not have "..v.." item in item_conf")
				end
			end
			return t
		end
	end
end

return monster



