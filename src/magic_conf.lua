local damageflow = require "damageflow"
local magic_conf = {
	["暴击术"] = {
		id = 1,
		name = "暴击术",
		level = 1,
		maxlevel = 10,
		needmp = 20,
		need = {
			level = 10,
			job = 1 + 2 + 4 + 8,
		},
		damage = function(owner, lv)
			return damageflow.criticalmagic, owner.physicaldamage * (lv + 1)
		end,
		explanation = "对敌人造成200%基础攻击力伤害"
	}
}

return magic_conf