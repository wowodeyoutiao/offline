local skynet = require "skynet"

local monster = require "monster"
local player = require "player"
local game_utils = require "game_utils"
local actor = require "actor"
local damageflow = require "damageflow"
local fightscene_conf = require "fightscene_conf"

local fightsceneid = ...
local  CMD = {}
local fightscene = {}
local actorlist = {}
local ordinary_monster = {}
local boss_monster = {}

function fightscene.find_monster()
	local ret = {} 
	for i=1,fightscene.round_monster_count do
		local  mon = ordinary_monster[i]:clone()
		table.insert(ret, mon)
	end
	return ret
end

function gen_clientmonster(mons)
	local r = {}
	for i,v in ipairs(mons) do
		local m = {}
		m.id = v.id
		m.name = v.name
		m.level = v.attri.level
		m.hp = v.attri.hp
		m.mp = v.attri.mp
		table.insert(r, m)
	end
	if #r == 0 then return nil end
	return r
end

function fightscene.fight()
	local fight_rate = fightscene.fight_rate * 100
	print(fight_rate)
	while true do
		skynet.sleep(1)
		local now = skynet.now()
		for _, _player in pairs(actorlist) do-- find every player
			if now - _player.lastfight >= fight_rate then
				local mons = fightscene.find_monster()
				if #mons > 0 then
					local df = {}
					print(88888)
					_player.fightmonster = gen_clientmonster(mons)
					fightscene.fightround(_player, mons, df)
					--if _player.online then 
						
						_player.damageflow = df
					--end
					_player.lastfight = now
				end
			end
		end
	end
end

function fightscene.fightround(player ,monsters, df)
	local tempplayer = {}
	if not player then return end
	tempplayer = player:clone()
	while true do
		for i,v in ipairs(monsters) do
			tempplayer:fight(v, df)
		end
		local alive = true
		for i,v in ipairs(monsters) do
			alive = alive and v:isalive()
		end
		if not alive then break end
		for i,v in ipairs(monsters) do
			v:fight(tempplayer, df)			
		end
		if not tempplayer:isalive() then break end	
	end
end
function CMD.online(playerid)
	print "online"
	assert(actorlist[playerid])
	if actorlist[playerid] then
		local p = actorlist[playerid]
		p.lastfight = 0
		p.online = true
	end
end

function CMD.offline(playerid)
	assert(actorlist[playerid])
	if actorlist[playerid] then
		local p = actorlist[playerid]
		p.online = false
	end	
end
function CMD.new_player(name, job, id)
	if job then
		local p = player.new(job) 
		if not p then return end 
		p.name = name
		p.lastfight = 0
		p.id = id
		p.sceneid = fightsceneid
		actorlist[id] = p
		fightscene.save_player(p.id)
		skynet.call("db", "lua", 1,"lpush", "scene."..fightsceneid, id)
		return true
	end
	return false
end

function CMD.delete_player(playerid)
	if actorlist[playerid] then
		fightscene.save_player(playerid)
		actorlist[playerid] = nil
		return true
	end
	return false
end

function CMD.get_player(playerid)
	print("get_player",playerid)
	assert(actorlist[playerid])
	return actorlist[playerid]
end

function db_call(...)
	return skynet.call("db", "lua", ...)
end

function CMD.load_player(playerid)
	local t = player.new()
	--skynet.call("db", "lua", playerid, "multi")
	for k,v in pairs(t.attri) do
		if type(v) ~= "table" then
			local r = skynet.call("db", "lua", playerid,"get", "player."..playerid..".attri."..k)
			t.attri[k] = tonumber(r)
		else
		end
	end
	t.name = skynet.call("db", "lua", playerid, "get", "player."..playerid..".name")
	t.sceneid = fightsceneid
	t.id = playerid
	t.lastfight = 0
	actorlist[playerid] = t
	--skynet.call("db", "lua", playerid, "exec")
end

function fightscene.save_player(playerid)
	print("save_player", playerid)
	--skynet.call("db", "lua", playerid, "MULTI")
	local p = actorlist[playerid]
	for k,v in pairs(p.attri) do
		if type(v) == "table" then
			for m, n in pairs(v) do
				skynet.call("db", "lua", playerid,"set", "player."..playerid..".attri."..k.."."..m, n)
			end
		else
			skynet.call("db", "lua", playerid,"set", "player."..playerid..".attri."..k, v)
		end
	end
	skynet.call("db", "lua", playerid, "set", "player."..playerid..".name", p.name)
	skynet.call("db", "lua", playerid, "set", "player."..playerid..".sceneid", fightsceneid)
	--skynet.call("db", "lua", playerid, "exec")
end

function CMD.getfightround(playerid)
	assert(actorlist[playerid])
	local p = actorlist[playerid]
	return  {monster = p.fightmonster, damageflow = p.damageflow}
end

function fightscene.loadthissceneplayer()
	local r = skynet.call("db", "lua", 1,"lrange", "scene."..fightsceneid, 0, -1)
	for k,v in ipairs(r) do
		CMD.load_player(v)
	end
end

function gen_monster(monster_conf, list)
	for k,v in pairs(monster_conf) do
		local mon = monster.new(v.monster)
		if not mon then return end
		mon.name = v.name
		if v.init then
			mon.attri.level = v.level
			if mon then mon:set_default_attri(v.init) end
		end		
		list[k] = mon
	end
end

function init(id)
	local v = fightscene_conf[id]
	if not v then return end
	fightscene.round_monster_count = v.round_monster_count
	fightscene.fight_rate = v.fight_rate
	fightscene.name = v.name		
	ordinary_monster = {}
	boss_monster = {}
	gen_monster(v.scene, ordinary_monster)	
	gen_monster(v.boss, boss_monster)
	return true
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = CMD[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	if not init(tonumber(fightsceneid)) then print("fightscene init fail") end
	fightscene.loadthissceneplayer()
	skynet.fork(assert(fightscene.fight))
	skynet.register("fightscene"..fightsceneid)
end)



