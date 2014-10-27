local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local redis = require "redis"
local sproto = require  "sproto"

local  REQUEST = {}
local host
local send_request
local db
local gate

function db_call(cmd, ...)
	return db[cmd](db, ...)
end

function login_server.auth(username, password)
	local name = "account."..username
	local id = db_call("get", name)
	if id then
		local pw = db_call("get",name..id..".password")
		if password == pw then return id end
	end
	return false
end

function login_server.new_account(name, password)
	local account = "account."..name
	local ok = db_call("exists", account)
	if not ok then
		local id = db_call("incr", "account.count")
		db_call("set", account, id)
		db_call("set", account..id..".password", password)
		db_call("rpush", "account.userlist", id)
		return true
		
	else
		return false
	end
end

function login_server.start(g, proto)
	host = sproto.new(proto.c2s):host "package"
	send_request = host:attach(sproto.new(proto.s2c))
	gate = g
end

function login_server.open(fd)
	print ( "client: "..fd)
	skynet.call(gate, "lua", "forward", fd, fd)
end

function REQUEST:createaccount()
	print("createaccount", self.username, self.password)
	local r = login_server.new_account(self.username, self.password)
	if not r then
		return {ok = false}
	else
		return {ok = true}
	end
end

function REQUEST:login()
	print("login", self.username, self.password)
	local r = login_server.auth(self.username, self.password)
	if not r then
		return {ok = false}
	else
		skynet.call("watchdag", "lua", "forward", fd)
		return { ok = true, id = r}
	end
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(fd, pack)
	local size = #pack
	local package = string.char(bit32.extract(size,8,8)) ..
		string.char(bit32.extract(size,0,8))..
		pack
	socket.write(fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (session, source, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(source, result)
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

skynet.start(function()
	db = redis.connect({
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	})
		
	local ok  = db:exists("account.count")
	if not ok then 
		db:set( "account.count", "0")
	end
	ok = db:exists("actor.count")
	if not ok then 
		db:set( "actor.count", "0")
	end
	print("start account server ok")
	skynet.register "account_server"
end)
