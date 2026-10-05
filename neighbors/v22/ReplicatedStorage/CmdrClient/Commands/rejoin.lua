return {
	Name = "rejoin",
	Aliases = { "" },
	Description = "Rejoins a player or set of players.",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to rejoin."
		}
	}
}