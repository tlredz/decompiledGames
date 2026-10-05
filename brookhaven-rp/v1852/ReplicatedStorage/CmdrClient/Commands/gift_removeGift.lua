return {
	Name = "gift_removeGift",
	Aliases = {},
	Description = "Remove a gift from a player",
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