return {
	Name = "setminutes",
	Aliases = { "set-minutes" },
	Description = "Adjusts a player or set of players minutes",
	Group = "CommunityManager",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to adjust the minutes of."
		},
		{
			Type = "integer",
			Name = "minutes",
			Description = "The minutes value"
		}
	}
}