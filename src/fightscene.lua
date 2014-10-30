local skynet = require "skynet"

local fightround = require "fightround"
local monster = require "monster"
local player = require "player"
local game_utils = require "game_utils"
local actor = require "actor"
local damageflow = require "damageflow"

local fightsceneid = ...
local fightscene_conf, ordinary_monster, boss_monster


local  CMD = {}

local fightscene = {}

local playerlist = {}

function fightscene.find_monster()
	local ret = {}
	for i=1,fightscene_conf.round_monster_count do
		local max = #ordinary_monster
		local mon = ordinary_monster[max]
		mon = mon:clone()
		table.insert(ret, mon)
	end
	return ret
end

function fightscene.fight()
	while true do
		skynet.sleep(500)
		print("fight")
		local now = skynet.now()
		local fight_rate = fightscene_conf.fight_rate
		print("fight_rate", fight_rate)
		for _,player in ipairs(playerlist) do-- find every player
			print("fight22221", now, player.lastfight)
			if now - player.lastfight >= fight_rate then
				print("fight1")
				local mons = assert(fightscene.find_monster(i))
				print("fight2")
				if #mons > 0 then
					local df = {}
					local actors = {}
					actors[player.id] = player:clone()
					for i,v in ipairs(mons) do
						actors[v.id] = v:clone()
					end
					fightround.fight(player, mons, df)			
					local tempplayer = player:clone() 
					for i,v in pairs(df) do 
						print(actors[v.src].name.." 对 "..actors[v.dest].name.."使用"..damageflow.get_damage_name(v.type)
							.."造成"..tostring(v.damage)..damageflow.get_damage_type(v.type))
						actors[v.dest].attri.hp = actors[v.dest].attri.hp - v.damage 
					end
					player.lastfight = now
				end
			end
		end
	end
end

function CMD.changescene(playerid, sceneid)
end

function CMD.new_player(name, job)
	if job then
		local newplayer = player.new(job) 
		if not newplayer then return end 
		newplayer.lastfight = 0 print(33)
		playerlist[newplayer.id] = newplayer 
		return true
	end
	return false
end

function CMD.get_player(playerid)
	assert(playerlist[playerid])
	return playerlist[playerid]
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

function CMD.start(...)
	fightscene_conf, ordinary_monster, boss_monster = ...
end

function fightscene.save_player(playerid)
	--[[
	db:multi()
	for k,v in pairs(player.attri) do
		db:hset("actor."..playerid..".attri",k, v)
	end
	db:exec()
	]]
end

function fightscene.getfightround(playerid)
	return {monster = {}, damageflow = {}}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		print(cmd,...)
		local f = CMD[string.lower(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.fork(assert(fightscene.fight))
	skynet.register("fightscene"..tostring(fightsceneid))
end)



