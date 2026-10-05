return {
	Name = "eventshopstock",
	Aliases = { "esstock" },
	Description = "Set the max stock of a limited event shop listing and refill it for every player, on every server.",
	Group = "Debug",
	Args = {
		{
			Type = "eventShop",
			Name = "shop",
			Description = "Event shop id."
		},
		{
			Type = "eventShopTarget",
			Name = "target",
			Description = "Limited base slot id, added listing id (extra_...), or its item key."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "New max stock per player (0-99)."
		},
		{
			Type = "itemTier",
			Name = "tier",
			Description = "Tier to match when the target is an item key.",
			Optional = true
		}
	}
}