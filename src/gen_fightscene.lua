local skynet = require "skynet"
local fightscene_conf = require "fightscene_conf"
local monster = require "monster"

local fightscene = {}
local ordinary_monster = {}
local boss_monster = {}

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

function init()
	for k,v in ipairs(fightscene_conf) do
		fightscene[k] = {
			round_monster_count = v.round_monster_count,
			fight_rate = v.fight_rate,
			name = v.name

		}		
		ordinary_monster[k] = {}
		boss_monster[k] = {}
		gen_monster(v.scene, ordinary_monster[k])	
		gen_monster(v.boss, boss_monster[k])
	end
end

skynet.start(function()
	init()
	for i=1,#fightscene do
		skynet.newservice("fightscene", i)
		skynet.call("fightscene"..tostring(i), "lua", "start", fightscene[i], ordinary_monster[i], boss_monster[i])
	end
end)






