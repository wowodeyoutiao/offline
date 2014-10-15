local actor = require "actor"

local player = {
	
}

setmetatable(player, actor)

function player.new()
	local t = {}
	setmetatable(t, player)
	return t
end

function player:add_to_bag(item)
    table.insert(self.bag, item)
end

function player:del_to_bag(item)
    for i,v in ipairs(self.bag) do
        if v = item then table.remove(self.bag, i) end
    end
end