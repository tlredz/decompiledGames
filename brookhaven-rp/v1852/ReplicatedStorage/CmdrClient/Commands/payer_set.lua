return {
	Name = "payer_set",
	Aliases = {},
	Description = "Set player payer timestamp (none to set as non-payer)",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "number",
			Name = "timestamp",
			Description = "Payer",
			Optional = true
		}
	}
}