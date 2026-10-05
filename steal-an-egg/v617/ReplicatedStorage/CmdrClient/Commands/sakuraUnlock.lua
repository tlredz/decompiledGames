return {
	Name = "sakuraUnlock",
	Description = "Unlocks or re-seals the Sakura Incubator for the players.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to change."
		},
		{
			Type = "boolean",
			Name = "Unlocked",
			Description = "true to unlock, false to seal."
		}
	}
}