local monster = require "monster"
local player = require "player"
local fightround = {}
local tempplayer = {}
function fightround.fight(player ,monsters)
	if not player then return end
	player:clone(tempplayer)
	while true do
		for i,v in ipairs(monsters) do
			tempplayer:fight(v)
		end
		local alive = false
		for i,v in ipairs(monsters) do
			alive = alive and v:isalive()
		end
		if not alive then break end

		for i,v in ipairs(monsters) do
			v:fight(tempplayer)
		end
		if not player:isalive() then break end		
	end
end

return fightround