return {
	Name = "givewins",
	Aliases = { "gwins", "givewin" },
	Description = "Give Wins through the active-session pipeline (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "amount",
			Description = "Wins amount to award (can be negative)."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}