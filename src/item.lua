local item = {}
local item_conf = require "item_conf"
--local db = require "db"
local function getid()
	return  1
--	return db:get("item.count")
end
function item.new(name)
	local titem = item_conf[name]
	if not titem then return end
	local t = setmetatable({}, item)
	for k,v in pairs(titem) do
		t[k] = v
	end
	t.id = getid()
	return t
end

return item