local db_conf = require "db_conf"
local redis = require "redis"
local skynet = require "skynet"

local dbs = {}
local dbcount = 0
local  function command(id, cmd, ...)
	local rediscmd = assert(dbs[id % dbcount + 1])
	return rediscmd(...)
end

skynet.start(function()
	for i,v in ipairs(db_conf) do
		dbcount = dbcount + 1
		dbs[i] = redis.connect(v)
	end
	skynet.dispatch("lua", function(session, source, ...)
			skynet.ret(skynet.pack(command(...)))
	end)
end
)