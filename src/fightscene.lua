local skynet = require "skynet"
local redis = require "redis"

local fightround = require "fightround"
local fightscene_conf = require "fightscene_conf"
local monster = require "monster"
local player = require "player"
local player_conf = require "player_conf"
local game_utils = require "game_utils"


local  CMD = {}

local fightscene = {}
local ordinary_monster = {}
local boss_monster = {}

function gen_monster(monster_conf, list)
	for k,v in pairs(monster_conf) do
		local mon 
		if v.default then
			mon = monster.new()
			if mon then mon:set_default_attri(v.default) end
		else
			mon = monster.new(v)
			if mon then mon.name = v.name end
		end
		if mon then list[k] = mon end
	end
end

function fightscene.init()
	for k,v in pairs(fightscene_conf) do
		fightscene[k] = {
		round_monster_count = v[round_monster_count],
		fight_rate = v[fight_rate]
		}
		ordinary_monster[k] = {}
		gen_monster(v.scene, ordinary_monster[k])
		boss_monster[k] = {}
		gen_monster(v.boss, boss_monster[k])
	end
end

function fightscene.find_monster(player)
	local curr_scene = fightscene[player.id]
	local ret = {}
	for i=1,curr_scene.round_monster_count do
		local curr_monsterlist = ordinary_monster[k]
		local max = #curr_monsterlist
		local mon = curr_monsterlist[math.random(1, curr_monsterlist)].clone()
		table.insert(ret, mon)
	end
	return ret
end

function fightscene.fight()
	while true do
		skynet.sleep(100)
		local now = skynet.now()
		for _,scene in pairs(fightscene) do -- in every scene
			local fight_rate = scene.fight_rate
			for _,player in ipairs(scene) do-- find every player
				if now - player.lastfight >= fight_rate then
					local mons = fightscene.find_monster(player)
					if #mons > 0 then
						fightround.fight(player, mons)
						player.lastfight = now
					end
				end
			end
		end
	end
end

function fightscene.save_player(player)
		redis:multi()
		for k,v in pairs(player.attri) do
			redis:hset("actor."..playerid..".attri",k, v)
		end
		redis:exec()
end

function fightscene.startscene(player, id)
	if not fightscene[id] then return false end
	fightscene[id][player.id] = player
	player.sceneid = id
	player.lastfight = 0
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

function CMD.new_player(playerid, job)
	if job and (job > 0) and (job < player_conf.job_count) then
		local newplayer = player.new(player_conf[job])
		newplayer.id = playerid
		fightround.save_player(newplayer)
		fightscene.startscene(newplayer, 1)
	end
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
	fightscene.init()
	skynet.fork(fightscene.fight)
	skynet.register "fightscene"
end)



