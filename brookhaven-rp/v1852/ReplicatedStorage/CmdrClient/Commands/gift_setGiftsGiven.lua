return {
	Name = "gift_setGiftsGiven",
	Aliases = {},
	Description = "Set the number of gifts given for a player",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "nonNegativeInteger",
			Name = "giftsGiven",
			Description = "number of gifts given"
		}
	}
}