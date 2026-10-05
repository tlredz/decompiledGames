return {
	Name = "giveitems",
	Aliases = { "gitem", "giveitem" },
	Description = "Give tiered items to a player (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "item",
			Name = "itemKey",
			Description = "Item config key (e.g. CaramelBow)."
		},
		{
			Type = "itemTier",
			Name = "tier",
			Description = "Item tier (0–5).",
			Optional = true,
			Default = 0
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "How many to grant.",
			Optional = true,
			Default = 1
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}