local damageflow = {
	none = 1,
	damage = 2,
	criticaldamage = 3,
	spelldamage = 4,
	renew = 5,
	criticalmaigc = 6,
}

local damagetype = {
	{id = "无效伤害", type ="物理伤害"},
	{id = "普通攻击", type = "物理伤害"},
	{id = "普通攻击", type = "暴击伤害"},
	{id = "魔法伤害", type = "魔法伤害"},
	{id = "生命回复", type = "生命值"},
	{id = "魔法回复", type = "魔法值"},
	{id = "暴击术", type = "物理伤害"}
}

function damageflow.add(df, atype,asrc, adest, adamage)
	table.insert(df, {type = atype, src = asrc, dest = adest, damage = adamage})
end

function damageflow.get_damage_type(id)
	if (id > 0) and (id < #damagetype) then
		return damagetype[id].type
	end
end

function damageflow.get_damage_name(id)
	if (id > 0) and (id < #damagetype) then
		return damagetype[id].name
	end
end
return damageflow