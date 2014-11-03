package.cpath = "./../skynet/luaclib/?.so"
package.path =package.path.. ";./../skynet/lualib/?.lua;"

local socket = require "clientsocket"
local bit32 = require "bit32"
local proto = require "proto"
local sproto = require "sproto"
local damageflow = require "damageflow"

local sessionpool = {}

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	local size = #pack
	local package = string.char(bit32.extract(size,8,8)) ..
		string.char(bit32.extract(size,0,8))..
		pack

	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args, func)
		session = session + 1
		sessionpool[session] = func
		local str = request(name, args, session)
		send_package(fd, str)
end

local last = ""

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session1, args)
	if (sessionpool[session1]) then
		sessionpool[session1](args)
		sessionpool[session1] = nil
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)

	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		print_package(host:dispatch(v))
	end
end
local wait1 = 0
function wait()
	while wait1 == 0 do
		socket.usleep(100)
		dispatch_package()
	end
	wait1 = 0
end

function notwait()
	wait1 = 1
end
function createaccount()
	send_request("createaccount", { username = "anmeng", password = "iloveyou" }, function(args)
		for k,v in pairs(args) do
			print(k,v)
		end
		notwait()
		login()
	end)
	wait()
end

function login()
	send_request("login", { username = "anmeng", password = "iloveyou" }, function(args)
		for k,v in pairs(args) do
			print(k,v)
		end
		notwait()
		if not args.ok then createaccount() end 
	end)
	wait()
end

function createplayer()
send_request("createplayer", { username = "anmeng", job = 1}, function (args)
		for k,v in pairs(args) do
			print(k,v)
		end
		if args.id > 0 then print "create actor succeed" end
		notwait()
	end)
	wait()
end

function getplayerinfo()
	send_request("getplayerinfo", {}, function (args)
		if args.ok then 
			print("getplayerinfo ok")
		else
			createplayer()
		end
		notwait()
	end)	
	wait()	
end

function getfightround()
	send_request("getfightround", {}, function (args)
		mon = args.monster
		df = args.damageflow
		notwait()
	end)	
	wait()
end

local player = nil
local mon = nil
local df = nil
login()
getplayerinfo()
getfightround()
while true do
	dispatch_package()
	if player and mon then
		local actor = {}
		actor[player.id] = player
		actor[mon.id] = mon
		for i,v in ipairs(df) do
			print(actors[v.src].name.." 对 "..actors[v.dest].name.."使用".. 
		damageflow.get_damage_name(v.type).."造成"..v.damage..damageflow.get_damage_type(v.type))
		end
		print("休息："..tostring(player.fightrate * 1000))
		socket.usleep(player.fightrate * 1000)
		player = nil
		mon = nil
		df = nil
		getplayerinfo()
		getfightround() 
	end
end
