local actor = require "actor"
local game_utils = require "game_utils"
local damageflow = require "damageflow"

local player = {}

setmetatable(player, actor)

function player.new(player_init)
	local t = actor.new()
	setmetatable(t, player)
	if player_init then game_utils.copy_attri(t.attri, player_init) end
	return t
end

function player:add_to_bag(item)
    table.insert(self.bag, item)
end

function player:del_to_bag(item)
    for i,v in ipairs(self.bag) do
        if v == item then table.remove(self.bag, i) end
    end
end

function player:fight(target, df)
	local critical ,damage = self.getphysicaldamage()
	damage = target:beingphysicalattack(damage)
	if critical then
		damageflow.add(damageflow.criticaldamage, self.id, target.id, damage)
	else
		damageflow.add(damageflow.damage, self.id, target.id, damage)
	end
end