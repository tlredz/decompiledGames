return {
	Name = "gear",
	Aliases = { "" },
	Description = "Give player a gear",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give the gear too."
		},
		{
			Type = "integer",
			Name = "gear id",
			Description = "The id of the gear to give."
		}
	}
}