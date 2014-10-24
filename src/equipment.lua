local item_conf = require "item_conf"
local game_utils = require "game_utils"
local equipment = {
totalid = 1
}
--get a new equipment
local function equipment.new(id)
	assert(item_conf[id])
	local t = setmetatable({}, equipment)
	t.id = equipment.totalid	
	for k,v in pairs(item_conf[id]) do
		t[k] = v
	end
	equipment.totalid = equipment.totalid + 1
	return t
end

local function equipment:add_attri(actor)
	game_utils.add_attri(actor.attri, self)
end

local function equipment:del_attri(actor)
	game_utils.del_attri(actor.attri, self)
end

