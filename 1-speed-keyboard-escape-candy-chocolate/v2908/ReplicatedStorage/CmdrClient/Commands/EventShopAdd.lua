return {
	Name = "eventshopadd",
	Aliases = { "esadd" },
	Description = "Add a limited listing to an event shop until the next restock, on every server.",
	Group = "Debug",
	Args = {
		{
			Type = "eventShop",
			Name = "shop",
			Description = "Event shop id."
		},
		{
			Type = "eventItem",
			Name = "itemKey",
			Description = "Item key from the shop's event."
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
			Description = "Max stock per player (1-99).",
			Optional = true,
			Default = 1
		},
		{
			Type = "integer",
			Name = "price",
			Description = "Currency price. Omit to use the shop's price for the item rarity.",
			Optional = true
		}
	}
}