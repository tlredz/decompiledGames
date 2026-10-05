return {
	Name = "hat",
	Aliases = { "" },
	Description = "Give a hat to players",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give a hat too."
		},
		{
			Type = "integer",
			Name = "gear id",
			Description = "ID of hat"
		}
	}
}