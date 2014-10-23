--local db = {}
local redis = require "redis"
--[[
local redispoll = {}
local current
function dbpoll.command(cmd)
	local r = redispoll[current]
	return redis[cmd]
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
			local f = assert(dbpoll.command[cmd])
			skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register "dbpoll"
end)
]]

local conf = {
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	}
local db = redis.connect(conf)
return db