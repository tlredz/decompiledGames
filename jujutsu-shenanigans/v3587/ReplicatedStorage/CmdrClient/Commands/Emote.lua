return {
	Name = "emote",
	Description = "Adds / Remove an emote from a player's inventory",
	Group = { "Owner", "Developer" },
	Args = {
		{
			Type = "player",
			Name = "Player"
		},
		{
			Type = "string",
			Name = "Emote"
		},
		{
			Type = "boolean",
			Name = "Clear"
		}
	}
}