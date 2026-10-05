return {
	Name = "giveBossTokens",
	Description = "Gives the player Boss Tokens.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to give tokens to."
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "The amount of tokens to give."
		}
	}
}