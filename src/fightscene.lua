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

function set_player(id, player)
	actorlist[id] = player
end

function get_player(playerid)
	return actorlist[playerid]
end

function fightscene.find_monster()
	local ret = {} 
	for i=1,fightscene.round_monster_count do
		local  mon = ordinary_monster[i]:clone()
		table.insert(ret, mon)
	end
	return ret
end

function fightscene.fight()
	while true do
		skynet.sleep(300)
		print("fight", #actorlist)
		local now = skynet.now()
		local fight_rate = fightscene.fight_rate
		for _,player in pairs(actorlist) do-- find every player
			if now - player.lastfight >= fight_rate then
				local mons = fightscene.find_monster()
				if #mons > 0 then
					local df = {}
					local actors = {}
					actors[player.id] = player:clone()
					for i,v in ipairs(mons) do
						actors[v.id] = v:clone()
					end
					fightscene.fightround(player, mons, df)		
					local tempplayer = player:clone() 
					for i,v in pairs(df) do 
						print(actors[v.src].name.." 对 "..actors[v.dest].name.."使用"..damageflow.get_damage_name(v.type)
							.."造成"..tostring(v.damage)..damageflow.get_damage_type(v.type))
						actors[v.dest].attri.hp = actors[v.dest].attri.hp - v.damage 
						print(actors[v.dest].attri.hp)
					end
					player.lastfight = now
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

function CMD.new_player(name, job, id)
	if job then
		local player = player.new(job) 
		if not player then return end 
		player.lastfight = 0
		player.id = id
		player.sceneid = fightsceneid
		set_player(id, player)
		fightscene.save_player(player.id)
		return true
	end
	return false
end

function CMD.delete_player(playerid)
	if get_player(player) then
		fightscene.save_player(playerid)
		set_player(playerid, nil)
		return true
	end
	return false
end

function CMD.get_player(playerid)
	assert(get_player(playerid))
	return get_player(playerid)
end

function db_call(...)
	return skynet.call("db", "lua", ...)
end

function CMD.load_player(playerid)
	local player = player.new(1)
	--skynet.call("db", "lua", playerid, "multi")
	for k,_ in pairs(player.attri) do
		local v = skynet.call("db", "lua", playerid,"get", "player."..playerid..".attri."..k)
		player.attri[k] = v
	end
	player.name = skynet.call("db", "lua", playerid, "get", "player."..playerid..".name")
	player.sceneid = fightsceneid
	player.id = playerid
	player.lastfight = 0
	set_player(playerid, player)
	--skynet.call("db", "lua", playerid, "exec")
end

function fightscene.save_player(playerid)
	print("save_player", playerid)
	--skynet.call("db", "lua", playerid, "MULTI")
	local player = actorlist[playerid]
	for k,v in pairs(player.attri) do
		if type(v) == "table" then
			for m, n in pairs(v) do
				skynet.call("db", "lua", playerid,"set", "player."..playerid..".attri."..k.."."..m, n)
			end
		else
			skynet.call("db", "lua", playerid,"set", "player."..playerid..".attri."..k, v)
		end
	end
	skynet.call("db", "lua", playerid, "set", "player."..playerid..".name", player.name)
	skynet.call("db", "lua", playerid,"set", "player."..playerid..".sceneid", fightsceneid)
	--skynet.call("db", "lua", playerid, "exec")
end

function fightscene.getfightround(playerid)
	return {monster = {}, damageflow = {}}
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
		print("fs cmd :",cmd)
		local f = CMD[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	if not init(tonumber(fightsceneid)) then print("fightscene init fail") end
	skynet.fork(assert(fightscene.fight))
	skynet.register("fightscene"..fightsceneid)
end)



