return {
	Name = "reset",
	Aliases = { "kill" },
	Description = "Resets a player or set of players",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to reset."
		}
	}
}