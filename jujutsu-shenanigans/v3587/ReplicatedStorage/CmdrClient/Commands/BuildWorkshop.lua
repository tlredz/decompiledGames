return {
	Name = "buildworkshop",
	Description = "Loads a player's workshop upload into the game",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "string",
			Name = "Entry ID"
		}
	}
}