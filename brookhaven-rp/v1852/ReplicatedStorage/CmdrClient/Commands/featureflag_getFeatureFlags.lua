return {
	Name = "featureflag_getFeatureFlags",
	Aliases = {},
	Description = "Get all feature flags for a player",
	Group = "FeatureFlags",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "target player (local player if not specified)",
			Optional = true
		}
	}
}