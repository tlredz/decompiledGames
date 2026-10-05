return {
	Name = "partykick",
	Aliases = { "party-kick" },
	Description = "Removes a player or set of players from your party",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to kick."
		}
	}
}