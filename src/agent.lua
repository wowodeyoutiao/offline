local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local bit32 = require "bit32"

local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

function db_call(cmd, ...)
	return false
	--return skynet.call("db", lua, cmd, ...)
end

function REQUEST:getplayerinfo()
	print("getplayerinfo", self.id)
	local r = skynet.call("fightscene1", "lua", "get_player", self.id)
		for k,v in pairs(r) do
		print(k,v)
		if type(v) == "table" then
		for a,b in pairs(v) do
			print(a, b)
		end
		end
	end
	return { ok = true ,player = r.attri }
end

function REQUEST:getfightround()
	print("getfightround", self.id)
	local r = skynet.call("fightscene1", "lua", "getfightround", self.id)
	for k,v in pairs(r) do
		print(k,v)
		for a,b in pairs(v) do
			print(a, b)
		end
	end
	return {monster = r.monster, damageflow = r.damageflow}
end

function REQUEST.createplayer(self)
	local id = self.id
	local name = self.username
	local job = self.job
	local ok = skynet.call("fightscene1", "lua", "new_player", name, job)
	if ok then return {id = 1} end
	return {id = -1}
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local size = #pack
	local package = string.char(bit32.extract(size,8,8)) ..
		string.char(bit32.extract(size,0,8))..
		pack

	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}

function CMD.start(gate, fd, proto)
	host = sproto.new(proto.c2s):host "package"
	send_request = host:attach(sproto.new(proto.s2c)) 
	client_fd = fd 
	skynet.call(gate, "lua", "forward", fd) 
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
