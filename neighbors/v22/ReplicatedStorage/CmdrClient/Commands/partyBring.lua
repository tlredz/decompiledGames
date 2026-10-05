return {
	Name = "partybring",
	Aliases = { "party-bring" },
	Description = "Brings a player or set of players to your party",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to bring."
		}
	}
}