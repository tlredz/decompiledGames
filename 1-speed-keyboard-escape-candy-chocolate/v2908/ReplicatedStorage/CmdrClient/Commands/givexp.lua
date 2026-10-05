return {
	Name = "givexp",
	Aliases = { "gxp" },
	Description = "Give a fixed amount of XP to a player (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "amount",
			Description = "XP amount to award."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}