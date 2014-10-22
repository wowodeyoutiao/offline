local equipment_conf = require "equipment_conf"
local game_utils = require "game_utils"
local equipment = {
totalid = 1
}
--get a new equipment
local function equipment.new(id)
	local t =  {}
	t.id = equipment.totalid
	equipment.totalid = equipment.totalid + 1
	setmetatable(t, equipment)
	t.equipment = equipment_conf[id]
	return t
end

local function equipment:add_attri(actor)
	game_utils.add_attri(actor.attri, self.equipment)
end

local function equipment:del_attri(actor)
	game_utils.del_attri(actor.attri, self.equipment)
end

