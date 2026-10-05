return {
	Name = "gift_addGift",
	Aliases = {},
	Description = "Add a gift to a player",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "giftId",
			Name = "giftId",
			Description = "ID of developer product"
		}
	}
}