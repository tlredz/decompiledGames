return {
	Name = "eventshopswap",
	Aliases = { "esswap" },
	Description = "Replace the item of an event shop slot until the next restock, on every server.",
	Group = "Debug",
	Args = {
		{
			Type = "eventShop",
			Name = "shop",
			Description = "Event shop id."
		},
		{
			Type = "eventShopSlot",
			Name = "slot",
			Description = "Base slot id (Common, Mysterious, or a fixed listing's item key)."
		},
		{
			Type = "eventItem",
			Name = "itemKey",
			Description = "Replacement item key from the shop's event."
		},
		{
			Type = "integer",
			Name = "stock",
			Description = "New max stock per player (0-99), refilled for everyone. Limited slots only.",
			Optional = true
		}
	}
}