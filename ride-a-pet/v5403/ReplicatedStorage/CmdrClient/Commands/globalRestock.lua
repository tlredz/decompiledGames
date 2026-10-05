return {
	Name = "globalrestock",
	Aliases = { "grestock" },
	Description = "Sets a shop item to an exact amount on EVERY server.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "shopItem",
			Name = "itemName",
			Description = "The radar, lantern or food to set."
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "How many to put in stock everywhere. 0 sells it out."
		}
	}
}