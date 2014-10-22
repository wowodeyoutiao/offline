local damageflow = {
	damage = 1,
	criticaldamage = 2,
	spelldamage = 3,
	renew = 4，
}

function damageflow.add(self, type,src, dest, damage)
	table.insert(self, {type, src, dest, damage})
end

return damageflow