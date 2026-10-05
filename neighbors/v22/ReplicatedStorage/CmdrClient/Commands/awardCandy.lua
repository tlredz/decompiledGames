return {
	Name = "awardcandy",
	Aliases = { "give-candy" },
	Description = "Awards a player or set of players X candies",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give candies to."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "The amount of candies to give to the players."
		}
	}
}