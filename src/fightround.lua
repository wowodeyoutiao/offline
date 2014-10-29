local monster = require "monster"
local player = require "player"
local damageflow = require "damageflow"

local fightround = {}
local tempplayer = {}
function fightround.fight(player ,monsters)
	if not player then return end
	tempplayer = player:clone()
	local df = {}
	while true do
		for i,v in ipairs(monsters) do
			tempplayer:fight(v, df)
		end
		local alive = false
		for i,v in ipairs(monsters) do
			alive = alive and v:isalive()
		end
		if not alive then break end
		for i,v in ipairs(monsters) do
			v:fight(tempplayer, df)
		end
		if not templayer:isalive() then break end		
	end
	local actors = {}
	for i,v in ipairs(monsters) do
		actors[v.id] = v
	end
	actors[player.id] = player
	tempplayer = player:clone()
	for i,v in pairs(df) do
		print(actors[v.src].name.." 对 "..actors[v.dest].name.."使用"..damageflow.get_damage_name(v.type)
			.."造成"..tostring(v.damage)..damageflow.get_damage_type(v.type))
		print("player.hp = ",tempplayer.attri.hp)
		if v.dest == tempplayer.id then tempplayer.attri.hp = tempplayer.attri.hp - v.damage end
	end
end

return fightround
