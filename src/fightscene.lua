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
		for i,scene in ipairs(fightscene) do -- in every scene
			local fight_rate = scene.fight_rate
			print("fight2222", fight_rate)
			for _,player in ipairs(scene) do-- find every player
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
		--newplayer.id = playerid
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

function CMD.start(...)
	fightscene_conf, ordinary_monster, boss_monster = ...
	for i,v in ipairs(ordinary_monster) do
		for k,v1 in pairs(v) do
			print(k, v1)
		end
	end
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



