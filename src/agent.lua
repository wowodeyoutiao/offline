local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local bit32 = require "bit32"

local host
local send_request

local CMD = {}
local REQUEST = {}
local agent = {}
local client_fd
local playerid =  -1
local sceneid = -1

function db_call(...)
	return skynet.call("db", "lua", playerid, ...)
end

function REQUEST:getplayerinfo()
	if sceneid == -1 then return {ok = false} end	
	local r = skynet.call("fightscene"..sceneid, "lua", "get_player", playerid)
	if r then
	return { ok = true ,player = r.attri }
	else
	return { ok = false}	
	end
end

function REQUEST:getfightround()
	print("getfightround")
	local r = skynet.call("fightscene"..sceneid, "lua", "getfightround", playerid)
	return {monster = r.monster, damageflow = r.damageflow}
end

function REQUEST:createplayer()
	local name = self.username
	local job = self.job
	local l = db_call("exists", "player."..playerid)
	if l then return {id = -2} end
	local r = skynet.call("fightscene1", "lua", "new_player", name, job, playerid)
	if r then 
		db_call("set", "player."..playerid, playerid)
		db_call("set", "player."..playerid..".sceneid", 1)
		return {id = playerid} 
	end
	return {id = -1}
end

function REQUEST:changescene()
	if sceneid ~= -1 then
		skynet.call("fightscene"..sceneid, "lua", "delete_player", playerid)
		skynet.call("fightscene"..self.id, "lua", "load_player", playerid)
	end
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

function agent.loadplayer()
	local ok = db_call("exists", "player."..playerid)
	if ok then	
		sceneid	= db_call("get", "player."..playerid..".sceneid")
		local r = skynet.call("fightscene"..sceneid, "lua", "load_player", playerid)
		if ok then return {id = playerid} end
	end
	print("loadplayer fail"..tostring(playerid))
	return {id = -1}
end

function CMD.start(gate, d, proto)
	host = sproto.new(proto.c2s):host "package"
	send_request = host:attach(sproto.new(proto.s2c)) 
	client_fd = d.fd
	playerid =  d.id
	skynet.call(gate, "lua", "forward", d.fd) 
	agent.loadplayer()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
