local actor = require "actor"

local monster =  {}

setmetatable(monster, actor)

local function monster.new()
	local t  =  {}
	setmetatable(t, monster)
	return t
end