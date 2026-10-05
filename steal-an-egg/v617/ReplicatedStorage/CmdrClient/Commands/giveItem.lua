return {
	Name = "giveItem",
	Description = "Gives gear, Index weapons, Monster Chests or Fractured Crystals immediately, for testing.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to give items to. Use me for yourself."
		},
		{
			Type = "item",
			Name = "Item",
			Description = "The item name or ID. Quote names containing spaces."
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "How many to give (default 1). Unique gear requires 1; inventory limits apply.",
			Default = 1
		}
	}
}