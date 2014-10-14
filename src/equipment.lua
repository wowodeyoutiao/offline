local equipment_conf = require "equipment_conf"
local equipment_mgr = {
}
--get a new equipment
local function equipment_mgr.new(id)
	local t =  {}
	local equipment_model = equipment_conf[id]
	t.position = equipment_model.position
	if equipment_model.hp then t.hp = equipment_model.hp end
	return t
end

local function equipment_mgr:add_actor(actor)
	-- body
end

