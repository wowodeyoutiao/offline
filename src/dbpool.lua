local skynet = require "skynet"
local dbpool = {}
skynet.start(function()
	local dbpoolcount = skynet.getenv("dbpoolcount")
	local current = 1
	for i=1,dbpoolcount do
		dbpool[i] = skynet.newservice "db"
		print("db"..dbpoolcount)
	end
	skynet.dispatch("lua", function(session, source, ...)
		skynet.ret(skynet.call(dbpool[current % dbpoolcount + 1], "lua", ...))
		current = current + 1
	end)
	skynet.register "db"
end)