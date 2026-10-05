return {
	Name = "code",
	Description = "Adds / Remove a code from a player's data",
	Group = { "Owner", "Developer" },
	Args = {
		{
			Type = "player",
			Name = "Player"
		},
		{
			Type = "string",
			Name = "Code"
		},
		{
			Type = "boolean",
			Name = "Clear"
		}
	}
}