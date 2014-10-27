local db_conf = require "db_conf"
local redis = require "redis"
local skynet = require "skynet"

local dbs = {}
local dbcount = 0
local  function command(id, cmd, ...)
	local db = assert(dbs[id % dbcount + 1])
	return db[cmd](db, ...)
end
skynet.start(function()
	for i = 1, #db_conf do
		dbcount = dbcount + 1
		dbs[i] = redis.connect(db_conf[i])
	end
	skynet.dispatch("lua", function(session, source, ...)
		skynet.ret(skynet.pack(command(...)))
	end)
end
)