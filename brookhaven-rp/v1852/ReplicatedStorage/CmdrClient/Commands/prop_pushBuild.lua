return {
	Name = "prop_pushBuild",
	Aliases = {},
	Description = "Serialize the current props and push them into a player's prop build slot",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "propBuild",
			Name = "propBuild",
			Description = "prop build slot (b1, b2, b3)"
		}
	}
}