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
	local r = skynet.call("fightscene", "lua", "get_player", self.id)
	return { ok = true ,player = r }
end

function REQUEST:getfightround()
	print("getfightround", self.id)
	local r = skynet.call("fightscene", "lua", "getfightround", self.id)
	return {monster = r.monster, damageflow = r.damageflow}
end

function REQUEST.createplayer(self)
	local id = self.id
	local name = self.username
	local job = self.job
	local actor = "actor."..name
	local ok = db_call("exists", actor)
	if not ok then		
		local actorid = db_call("incr", "actor.count")
		db_call("set", actor, actorid)
		db_call("sadd", "account."..id..".actors", actorid)
		actorid = 1
		local ok = skynet.call("fightscene", "lua", "new_player", actorid, name, job)
		if ok then return {id = actorid} end
		return {id = -1}
	end
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
