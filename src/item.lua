local item = {}
local item_conf = require "item_conf"
function item.new(name)
	local titem = item_conf[name]
	if not titem then return end
	local t = setmetatable({}, item)
	for k,v in pairs(titem) do
		t[k] = v
	end
	return t
end

return item