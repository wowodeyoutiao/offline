local actor = require "actor"
local game_utils = require "game_utils"
local damageflow = require "damageflow"
local player_conf = require "player_conf"

local player = {}
player.__index = player

setmetatable(player, actor)

function player.new(id)
	if not (id and player_conf[id]) then return end
	local t = actor.new()
	t.spellmagicorder = {}
	t.currentspellmagicorder = 1
	t.maxspellmaigccount = 1
	t.bag = {}--包裹
	game_utils.copy_attri(t.attri, player_conf[id]) 
	setmetatable(t, player)	
	return t
end

function player:addtobag(item)
	if item then
   		self.bag[item.id] = item
	end
end

function player:delfrombag(itemid)
	if self.bag[itemid] then
		self.bag[itemid] = nil
	end
end

function player:set_spell_magic_order(skillid, order)
	if (order <= self.maxspellmaigccount) and (self.skill[skillid]) then
		self.releaseskillorder[order] = skillid
		return true
	end
	return false
end

function player:getmagicdamage(nextmagic)
	local magicid = self.spellmagicorder[self.currentspellmagicorder]
	if magicid then
		local damagetype, damage = self:spell_magic(magicid)
	else
		return damageflow.none
	end

	if nextmagic then
		self.currentspellmagicorder = (self.currentspellmagicorder + 1) % self.maxspellmaigccount
	end
	
	if not damagetype then return damageflow.none end
	return damagetype, damage
end

function player:reinitspellmagic()
	self.currentspellmagicorder = 1
end
--[[
function player:fight(target, df)
	local damagetype, damage = self:getmagicdamage()
	if damagetype ~= damagetype.none then
		damage = target:beingspelldamage(damage)
		damageflow.add(damagetype.id, self.id, target.id, damage)
	end
	damagetype ,damage = self:getphysicaldamage()
	damage = target:beingphysicaldamage(damage)
	damageflow.add(damagetype.id, self.id, target.id, damage)
end
]]

return player