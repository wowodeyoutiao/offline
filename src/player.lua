local actor = require "actor"
local game_utils = require "game_utils"
local damageflow = require "damageflow"
local player_conf = require "player_conf"
local player_upgradeexp_conf = require "player_upgradeexp_conf"

local player = {}
player.__index = player

setmetatable(player, actor)

function player.new(id)	
	local t = actor.new()
	t.spellmagicorder = {}
	t.currentspellmagicorder = 1
	t.maxspellmaigccount = 1
	t.bag = {}--包裹
	if id and player_conf[id] and player_upgradeexp_conf[id] then 
		game_utils.copy_attri(t.attri, player_conf[id])
		t.attri.nextexperience = player_upgradeexp_conf[id][t.attri.level]
	end	
	setmetatable(t, player)	
	return t
end

function player:clone( )
	local t = player.new()
	t.currentspellmagicorder = self.currentspellmagicorder
	t.maxspellmaigccount = self.maxspellmaigccount
	for k,v in pairs(self.bag) do
		t.bag[k] = v
	end
	for k,v in pairs(self.spellmagicorder) do
		t.spellmagicorder[k] = v
	end
	t.id = self.id
	t.name = self.name
	game_utils.copy_attri(t.attri, self.attri) 
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

function player:upgrade(exp)
	print(self.name..' get '..tostring(exp)..' exp.', self.attri.nextexperience)
	self.attri.currentexperience = self.attri.currentexperience + exp
	if self.attri.currentexperience >= self.attri.nextexperience then
		self.attri.level = self.attri.level + 1
		self.attri.nextexperience = player_upgradeexp_conf[self.attri.job][self.attri.level]
		self.attri.currentexperience = 0
		print(self.name..'升级到'..tostring(self.attri.level)..'级')
		return true
	else
		return false
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