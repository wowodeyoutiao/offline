--[[
	1 技能书
]]
local damageflow = require "damageflow"
	
local  item_conf = {
	NECKLACE = 1,
	["LEFTRING"] = 2,
	["RIGHTRING"]= 3,
	["SHOE"]= 4,
	["BELT"]= 5,
	["HELMET"] = 6,
	["DRESS"]= 7,
	["WEAPON"] = 8,
	['exp1'] = { -- type = 0 is direct use item 
		type = -1,
		subtype = 1,
		experience = function()
			return 100
		end,
		howtouse = 'getexp'
	},
	['exp2'] = {
		type = -1,
		subtype = 2,
		experience = function(lv)
			return 100 + lv * 10
		end,
		howtouse = 'getexp'
	},	
	['exp3'] = {
		type = -1,
		subtype = 2,
		experience = function(lv)
			return 100 + math.random(1, 100)
		end,
		howtouse = 'getexp'
	},	
	["暴击术"] = {
		id = 1,
		type = 1,
		subtype = 1,
		name = "暴击术",
		howtouse = "spellbook",
		explanation = "对敌人造成200%基础攻击力伤害",
		need = {
			level = 10,
			job = 1 + 2 + 4 + 8,
		},
		magic = {
			level = 1,
			maxlevel = 10,
			needmp = 20,
			currlevelexp = 0,
			nextlevelexp = 0,
			getnextlevelexp = function(level)
				return 200 + level * 100
			end,
			damage = function(owner, lv)
				return damageflow.criticalmagic, owner.physicaldamage * (lv + 1)
			end
		}
	},
	["布衣(男)"] = {
		id = 2,
		position = NECKLACE,
		name = '布衣(男)',
		job = 0,
		need = {
			level = 10,
			job = 1 + 2 + 4 + 8,
		},
		hp = 100
	}
}

return item_conf