local skynet = require "skynet"
local redis = require "redis"

local fightround = require "fightround"
local fightscene_conf = require "fightscene_conf"
local monster = require "monster"
local player = require "player"
local game_utils = require "game_utils"
local actor = require "actor"

local  CMD = {}

local fightscene = {}
local ordinary_monster = {}
local boss_monster = {}
local db
local actorlist ={}

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

function fightscene.init()
	for k,v in ipairs(fightscene_conf) do
		fightscene[k] = {
		round_monster_count = v["round_monster_count"],
		fight_rate = v["fight_rate"]
		}
		ordinary_monster[k] = {}
		gen_monster(v.scene, ordinary_monster[k])
		boss_monster[k] = {}
		gen_monster(v["boss"], boss_monster[k])
	end
end

function fightscene.find_monster(sceneid)
	local curr_scene = fightscene[sceneid]
	local ret = {}
	for i=1,curr_scene.round_monster_count do
		local curr_monsterlist = ordinary_monster[i]
		local max = #curr_monsterlist
		local mon = curr_monsterlist[max]
		mon = mon:clone()
		table.insert(ret, mon)
	end
	return ret
end

function fightscene.fight()
	while true do
		skynet.sleep(100)
		local now = skynet.now()
		for i,scene in ipairs(fightscene) do -- in every scene
			local fight_rate = scene.fight_rate
			for _,player in ipairs(scene) do-- find every player
				if now - player.lastfight >= fight_rate then
					local mons = assert(fightscene.find_monster(i))
					if #mons > 0 then
						fightround.fight(player, mons)
						player.lastfight = now
					end
				end
			end
		end
		--]]
	end
end

function fightscene.startscene(player, id)
	if not fightscene[id] then return false end
	fightscene[id][player.id] = player
	player.sceneid = id
	player.lastfight = 0
	actorlist[player.id] = player 
	return true
end

function CMD.changescene(player, id)
	local curr_scene = fightscene[player.sceneid]
	if curr_scene[player.id] == player then
		curr_scene[player.id] = nil
		curr_scene = player
		return true
	end
	return false
end

function CMD.new_player(playerid, name, job)
	if job then
		local newplayer = player.new(job)
		if not newplayer then return end
		newplayer.id = playerid
		fightscene.startscene(newplayer, 1)
		return true
	end
	return false
end

function CMD.get_player(playerid)
	assert(actorlist[playerid])
	return actorlist[playerid]
end

function CMD.load_player(playerid)
	--[[
	local player = {}
	db:multi()
	for k,v in pairs(player.attri) do
		db:gset("actor."..playerid..".attri")
	end
	db:exec()
	]]
end

function fightscene.save_player(playerid)
	db:multi()
	for k,v in pairs(player.attri) do
		db:hset("actor."..playerid..".attri",k, v)
	end
	db:exec()
end

function fightscene.getfightround(playerid)
	return {monster = {}, damageflow = {}}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		print(...)
		local f = CMD[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	fightscene.init()
	skynet.fork(assert(fightscene.fight))
	local conf = {
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	}
	db = redis.connect(conf)
	skynet.register "fightscene"
end)



