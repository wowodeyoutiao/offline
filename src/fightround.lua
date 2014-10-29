local monster = require "monster"
local damageflow = require "damageflow"

local fightround = {}
local tempplayer = {}
function fightround.fight(player ,monsters, df)
	if not player then return end
	tempplayer = player:clone()
	while true do
		for i,v in ipairs(monsters) do
			tempplayer:fight(v, df)
		end
		local alive = true
		for i,v in ipairs(monsters) do
			alive = alive and v:isalive()
		end
		if not alive then break end
		for i,v in ipairs(monsters) do
			v:fight(tempplayer, df)			
		end
		if not tempplayer:isalive() then break end	
	end
end

return fightround
