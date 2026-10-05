return {
	Name = "eventshopremove",
	Aliases = { "esremove" },
	Description = "Remove an added listing, or clear a slot's swap and stock overrides, on every server.",
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
			Description = "Added listing id (extra_...), its item key, or a base slot id."
		},
		{
			Type = "itemTier",
			Name = "tier",
			Description = "Tier to match when the target is an item key.",
			Optional = true
		}
	}
}