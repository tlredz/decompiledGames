return {
	Name = "adjustStreak",
	Aliases = { "change-streak" },
	Description = "Changes a players streak",
	Group = "SeniorModerator",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "The player to change streak."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "Streak to change to."
		}
	}
}