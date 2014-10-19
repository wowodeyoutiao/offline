local skynet = require "skynet"

--local fight_round = require "fight_round"
local fightscene_conf = require "fightscene_conf"
local monster = require "monster"
local player = require "player"
local player_conf = require "player_conf"
local game_utils = require "game_utils"
local redis = require "redis"

local  CMD = {}

local fightscene = {}
local ordinary_monster = {}
local boss_monster = {}

function fightscene.fight(co)
	local i = 0
	while true do
		i = i + 1
		skynet.sleep(100)
		print("fuck", i)
	end
end

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
		fightscene[k] = {}
		ordinary_monster[k] = {}
		gen_monster(v.scene, ordinary_monster[k])
		boss_monster[k] = {}
		gen_monster(v.boss, boss_monster[k])
	end
end

function CMD.startscene(agent, id)
	if not fightscene[id] then return false end
	fightscene[id][agent.fd] = agent
	agent.sceneid = id
	return true
end

function CMD.changescene(agent, id)
	if fightscene[agent.sceneid][agent.fd] == agent then
		fightscene[agent.sceneid][agent.fd] = nil
		fightscene[id][agent.fd] = agent
		return true
	end
	return false
end

function CMD.load_player()
	
end

function CMD.new_player(agent, job)
	if job and (job > 0) and (job < player_conf.job_count) then
		local newplayer = player.new()
		game_utils.copy_attri(newplayer, player_conf[job])
		redis:multi()
		for k,v in pairs(newplayer) do
			redis:hset(k, v)
		end
		redis:exec()
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
	skynet.fork(fightscene.fight, coroutine.running())
	skynet.register "fightscene"
end)



