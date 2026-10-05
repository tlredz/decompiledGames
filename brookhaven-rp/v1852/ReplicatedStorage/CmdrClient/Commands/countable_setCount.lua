return {
	Name = "countable_setCount",
	Aliases = {},
	Description = "Set a player's count for a CountableDevProduct (works offline).",
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
			Description = "name of the countable dev product"
		},
		{
			Type = "integer",
			Name = "count",
			Description = "new count"
		}
	}
}