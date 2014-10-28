local player_conf = {
	job_count = 4,
	default_male_warrior = {
		level = 1,
		job = 1,
		hp = 2000,
		mp = 100,
		physicaldamage = 100
	},
	default_female_warrior = {
	level = 1,
	job = 2,
	hp = 2000,
	mp = 889,
	physicaldamage = 80
	},
	default_male_magician = {
		level = 1,
		job = 4,
		hp = 2000,
		mp = 100,
		physicaldamage = 100
	},
	default_female_magician = {
	level = 1,
	job = 8,
	hp = 2000,
	mp = 889,
	physicaldamage = 80
	}
}
player_conf[player_conf.default_male_warrior.job] = player_conf.default_male_warrior
player_conf[player_conf.default_female_warrior.job] = player_conf.default_female_warrior
player_conf[player_conf.default_male_magician.job] = player_conf.default_male_magician
player_conf[player_conf.default_female_magician.job] = player_conf.default_female_magician
return player_conf