return {
	Name = "data",
	Description = "Display all data of a player",
	Group = {
		"Owner",
		"HeadMod",
		"Developer",
		"Mod"
	},
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "number",
			Name = "Version",
			Optional = true
		}
	}
}