--package.path = "./examples/?.lua;" .. package.path

local skynet = require "skynet"
local netpack = require "netpack"
local proto = require "proto"

local CMD = {}
local SOCKET = {}
local gate
local agent = {}

function SOCKET.open(fd, addr)
	skynet.call("account_server", "lua", "open", fd)
end

local function close_agent(fd)
	local a = agent[fd]
	if a then
		skynet.kill(a)
		agent[fd] = nil
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.data(fd, msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
	skynet.call("account_server", "lua", "start", gate, proto)
end

function  CMD.startagent(fd, d)
	agent[fd] = skynet.newservice("agent")
	skynet.call(agent[fd], "lua", "start", gate, d, proto)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)
	skynet.register "watchdog"

	gate = skynet.newservice("gate")
end)
