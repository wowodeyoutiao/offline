local player_conf = {
	job_count = 2,
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
}
}
player_conf[1] = player_conf.default_male_warrior
player_conf[2] = player_conf.default_female_warrior
return player_conf