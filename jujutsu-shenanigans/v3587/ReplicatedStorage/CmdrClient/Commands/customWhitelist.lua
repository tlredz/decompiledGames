return {
	Name = "customWhitelist",
	Description = "Change player's permission to load custom movesets",
	Group = { "Owner", "HeadMod", "Developer" },
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "boolean",
			Name = "allow"
		},
		{
			Type = "boolean",
			Name = "allow loading movesets for other people",
			Optional = true,
			Default = false
		}
	}
}