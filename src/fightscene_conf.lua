local fight_scene_conf = {
	[1] = {
		round_monster_count = 2,
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
				name = "小小怪",
				level = 10,
				monster = "monster1",
				init = 1
			},
			{
				name = "小怪",
				level = 20,
				monster = "monster1",
				init = 1
			},
		}
	}
}
return fight_scene_conf
