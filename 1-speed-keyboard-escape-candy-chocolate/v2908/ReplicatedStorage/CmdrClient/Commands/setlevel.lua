return {
	Name = "setlevel",
	Aliases = { "sl" },
	Description = "Sets a player's level (default: yourself). Resets XP progress for that level.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "targetLevel",
			Description = "Target level (minimum 1)."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Player to update (default: you).",
			Optional = true
		}
	}
}