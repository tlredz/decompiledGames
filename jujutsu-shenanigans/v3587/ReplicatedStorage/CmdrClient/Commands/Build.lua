return {
	Name = "build",
	Description = "Loads a player's build into the game",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "number",
			Name = "Slot"
		},
		{
			Type = "number",
			Name = "Version",
			Optional = true
		}
	}
}