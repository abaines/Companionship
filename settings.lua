data:extend({
	{
		type = "int-setting",
		name = "minimum_number_of_companions",
		default_value = 2,
		minimum_value = 1,
		maximum_value = 42, -- Answer to the Ultimate Question of Life, the Universe, and Everything
		setting_type = "startup",
	},
	{
		type = "double-setting",
		name = "speed_when_below_minimum_number_of_companions",
		default_value = 0.16666, -- 10 Updates Per Second
		minimum_value = 0.05,
		maximum_value = 9001, -- It's Over 9000!
		setting_type = "startup",
	},
	{
		type = "double-setting",
		name = "player_desired_speed",
		default_value = 1,
		minimum_value = 0.05,
		maximum_value = 9001, -- It's Over 9000!
		setting_type = "runtime-per-user",
	},
})

