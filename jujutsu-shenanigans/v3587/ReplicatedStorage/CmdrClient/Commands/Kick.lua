return {
	Name = "kick",
	Description = "Removes the player from the server",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "player",
			Name = "Player"
		},
		{
			Type = "string",
			Name = "Reason",
			Optional = true
		}
	}
}