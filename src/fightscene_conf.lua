local fight_scene_conf = {
	[1] = {
		round_monster_count = 1,
		fight_rate = 5,
		name = "初章",
		boss = {
			{
				name = 'super boss',
				level = 2,
				monster = "default_monster1",
				init = 1
			}
		},
		scene = {
			{
				name = "monster100",
				level = 10,
				monster = "monster1"
			}
		}
	}
}
return fight_scene_conf
