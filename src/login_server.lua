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
end

function login_server.new_account(name, password)
	local ok, result = db:exists "account.count"
	if not ok then
		db:set("account."..name, password)
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
	local ok, result = db:exists "account.count"
	print(ok, result)
	if not result then db:set("account.count", "0") end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
			local f = assert(login_server[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
	end)
end)
