return {
	Name = "clearslot",
	Description = "Erases all data from a slot",
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