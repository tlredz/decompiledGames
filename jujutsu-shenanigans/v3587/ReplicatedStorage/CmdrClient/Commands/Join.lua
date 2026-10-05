return {
	Name = "join",
	Description = "Joins the server the player is currently in",
	Group = {
		"Owner",
		"Developer",
		"Contrib",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "string",
			Name = "Username"
		},
		{
			Type = "boolean",
			Name = "alternative method",
			Optional = true
		}
	}
}