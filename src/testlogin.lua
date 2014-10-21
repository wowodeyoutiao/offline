
local skynet = require "skynet"
skynet.start(function()
	skynet.newservice "login_server"
	skynet.call("login_server", "lua", "start")
	skynet.call("login_server", "lua", "new_account", "anmeng", "anmeng")
	local ret = skynet.call("login_server", "lua", "auth", "anmeng", "anmeng")
	print(ret)
	skynet.exit()
end)