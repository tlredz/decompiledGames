return {
	Name = "setintoxication",
	Aliases = { "" },
	Description = "Set players intoxication",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players to intoxicate."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "Intoxication level."
		}
	}
}