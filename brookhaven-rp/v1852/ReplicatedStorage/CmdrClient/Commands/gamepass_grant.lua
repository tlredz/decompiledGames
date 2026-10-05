return {
	Name = "gamepass_grant",
	Aliases = {},
	Description = "Simulate a gamepass purchase for a player at an optional custom timestamp",
	Group = "Product",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "target player (must be online)"
		},
		{
			Type = "gamepassId",
			Name = "gamepass",
			Description = "gamepass to simulate purchasing"
		},
		{
			Type = "number",
			Name = "timestamp",
			Description = "UnixTimestamp of the purchase; defaults to now",
			Optional = true
		}
	}
}