local skynet = require "skynet"
local db = require "db"
local dbpool = {}
skynet.start(function()
	local dbpoolcount = skynet.getenv("dbpoolcount")
	local current = 1
	for i=1,dbpoolcount do
		dbpool[i] = skynet.newservice "db"
	end
	skynet.dispatch("lua", function(session, source, ...)
		local d = dbpool[current % dbpoolcount + 1]
		current = current + 1		
		skynet.retpack(d.command(...))
	end)
	skynet.register "db"
end)