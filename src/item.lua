local item = {}
item.__index = item
local useitem = {}
local item_conf = require "item_conf"
local magic = require "magic"
local equipment = require "equipment"
--local db = require "db"
local function getid()
	return  1
--	return db:incb("item.count")
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
function item:use(player)
	assert(player)
	useitem[self.howtouse](player, self)
end
function useitem.spellbook(player, item)
	assert(player)
	assert(item)
	local m = magic.new(item.name)
	player.add_magic(m)
end

function useitem.equipment(player, item)
	assert(player)
	assert(item)
	local e = equipment(item.name)
	player:add_equipment(e)
end

return item