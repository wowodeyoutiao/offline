local skynet = require "skynet"
local netpack = require "netpack"
local redis = require "redis"
local login_server = {}
local db 
local function _encode(str)
    return string.format("%%%02X",string.byte(str))
end

function emailEncode(str)
    return string.gsub(str,"([^%w_@.])",_encode)
end

local function _decode(str)
    return string.char(tonumber(str,16))
end

function emailDecode(str)
    return string.gsub(str,"%%(%w%w)",_decode)
end
function login_server.auth(username, password)
	local name = "account."..username
	local id = db:get(name)
	if id then
		local pw = db:get(name..id..".password")
		if password == pw then return id end
	end
	return false
end

function login_server.new_account(name, password)
	local account = "account."..name
	local ok = db:exists(account)
	if not ok then
		local id = db:incr("account.count")
		db:set(account, id)
		db:set(account..id..".password", password)
		print "OK"
		return true
		
	else
		print "NO"
		return false
	end
end

function login_server.get_password(name)
end

function login_server.get_actors(name)

end

function login_server.create_actor(id, name)
end

function login_server.start()
	local conf = {
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	}
	db = redis.connect(conf)
	local ok  = db:exists "account.count"
	if not result then db:set("account.count", "0")  end
	print("start login server")
	return true
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
			local f = assert(login_server[cmd])
			skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register "login_server"
end)
