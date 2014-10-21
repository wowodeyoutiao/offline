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
	local name = db:get()
end

function login_server.new_account(name, password)
	local accout = "account."..name  
	local ok = db:exists(account)
	if not ok then
	
		local id = 
		db:set(account, db:incr("account.count"))
		db:set()
		return true
	else
		return false
	end
end

function login_server.get_password(name)
end

function login_server.get_actors(name)

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
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
			local f = assert(login_server[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))

	end)
	print("runing login server")
	login_server.start()
end)
