return {
	Name = "awardcredits",
	Aliases = { "give-credits" },
	Description = "Awards a player or set of players X credits",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give credits to."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "The amount of credits to give to the players."
		}
	}
}