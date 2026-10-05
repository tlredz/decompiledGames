return {
	Name = "fillRandomItems",
	Aliases = { "fillitems", "randomitems" },
	Description = "Fill a player's inventory with random items of random tiers.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "amount",
			Description = "How many random items to grant."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}