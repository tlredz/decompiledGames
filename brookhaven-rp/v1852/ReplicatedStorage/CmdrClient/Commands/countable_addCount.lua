return {
	Name = "countable_addCount",
	Aliases = { "countable_grant" },
	Description = "Grant a player additional CountableDevProduct purchases (additive).",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "countableProductId",
			Name = "productId",
			Description = "name of the countable dev product (e.g. PLUS_ONE_PS_PROPS_SLOT)"
		},
		{
			Type = "integer",
			Name = "quantity",
			Description = "number of purchases to add (default 1)",
			Optional = true
		}
	}
}