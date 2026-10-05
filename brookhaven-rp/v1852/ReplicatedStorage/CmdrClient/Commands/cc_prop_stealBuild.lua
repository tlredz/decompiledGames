return {
	Name = "cc_prop_stealBuild",
	Aliases = {},
	Description = "Load a player's prop build",
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
			Description = "prop build"
		},
		{
			Type = "string",
			Name = "version",
			Description = "profile version",
			Optional = true
		}
	}
}