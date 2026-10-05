return {
	Name = "giveitemall",
	Aliases = { "gitemall" },
	Description = "Give an item to every online player, on every server. Limited items are refused.",
	Group = "Debug",
	Args = {
		{
			Type = "item",
			Name = "itemKey",
			Description = "Item config key (e.g. CaramelApple)."
		},
		{
			Type = "itemTier",
			Name = "tier",
			Description = "Item tier (0-5).",
			Optional = true,
			Default = 0
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "How many each player receives (1-100).",
			Optional = true,
			Default = 1
		}
	}
}