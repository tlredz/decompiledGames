return {
	Name = "partyjoin",
	Aliases = { "party-join" },
	Description = "Joins a players party",
	Group = "Moderator",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The players to join."
		}
	}
}