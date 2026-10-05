return {
	Name = "loadhistory",
	Description = "Loads the history of a player's data",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod",
		"CustomMoveset"
	},
	Args = {
		{
			Type = "player",
			Name = "Player",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Raw",
			Optional = true
		}
	}
}