return {
	Name = "versionlist",
	Description = "Lists all versions of the file",
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
		}
	}
}