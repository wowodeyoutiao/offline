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
		print "gg"
		if not alive then break end

		for i,v in ipairs(monsters) do
			v:fight(tempplayer, df)
		end
		if not templayer:isalive() then break end		
	end
local actors = {[masters[1].id] = masters[1], [player.id] = player}
for i,v in ipairs(df) do
	print(actors[v.src].name.." 对 "..actors[v.dest].name.."使用".. 
		damageflow.get_damage_name(v.type).."造成"..v.damage..damageflow.get_damage_type(v.type))
end
end

return fightround