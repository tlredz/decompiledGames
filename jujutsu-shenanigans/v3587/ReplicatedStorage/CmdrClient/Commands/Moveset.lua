return {
	Name = "moveset",
	Description = "Loads a moveset into your inventory",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod",
		"Tester",
		"Youtuber"
	},
	Args = {
		{
			Type = "character",
			Name = "Moveset"
		},
		{
			Type = "boolean",
			Name = "Ultimate",
			Optional = true
		}
	}
}