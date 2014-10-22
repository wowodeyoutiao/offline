local monster = require "monster"
local player = require "player"
local damageflow = require "damageflow"

local fightround = {}
local tempplayer = {}
function fightround.fight(player ,monsters)
	if not player then return end
	player:clone(tempplayer)
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
		if not player:isalive() then break end		
	end
end

return fightround