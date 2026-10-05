return {
	Name = "giveeventcurrency",
	Aliases = { "gecurrency" },
	Description = "Give event currency to a player (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "eventCurrency",
			Name = "currency",
			Description = "Event currency key (e.g. CandyCorn)."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "Amount to give (1-1000000)."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}