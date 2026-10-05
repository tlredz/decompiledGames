return {
	Name = "rollback",
	Description = "Rollback their build data by the specified versions",
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
			Name = "Versions"
		}
	}
}