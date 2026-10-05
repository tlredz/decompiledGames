return {
	Name = "giveeventcurrencyall",
	Aliases = { "gecurrencyall" },
	Description = "Give event currency to every online player, on every server.",
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
			Description = "Amount each player receives (1-1000000)."
		}
	}
}