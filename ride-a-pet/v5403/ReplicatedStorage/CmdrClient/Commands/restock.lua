return {
	Name = "restock",
	Aliases = { "rs" },
	Description = "Sets a shop item to an exact amount on THIS server only.",
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
			Description = "How many to put in stock. 0 sells it out."
		}
	}
}