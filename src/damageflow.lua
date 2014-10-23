local damageflow = {
	none = 1,
	damage = 2,
	criticaldamage = 3,
	spelldamage = 4,
	renew = 5,
	criticalmaigc = 6,
}

local damagetype = {
	"ÎŞĞ§ÉËº¦",
	"ÆÕÍ¨¹¥»÷",
	"±©»÷",
	"Ä§·¨ÉËº¦",
	"ÉúÃü»Ø¸´",
	"±©»÷Êõ"
}

function damageflow.add(df, atype,asrc, adest, adamage)
	table.insert(df, {type = atype, src = asrc, dest = adest, damage = adamage})
end

function damageflow.get_damage_string(id)
	if (id > 0) and (id < #damagetype) then
		return damagetype[id]
	end
end
return damageflow