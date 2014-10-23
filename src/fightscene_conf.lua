	local fight_scene_conf = {
	1 = {
		round_monster_count = 2
		fight_rate = 10
		name = "初章"
		boss = {
			boss1 = {
				name = 'super boss',
				level = 2,
				default = "default_monster1"
			}
		},
		scene = {
			{
				name = "monster100",
				level = 10,
				default = "default_monster1",
			}
		}
	}
}
return fight_scene_conf