return {
	Name = "featureflag_removeOverride",
	Aliases = {},
	Description = "Remove override feature flag for a player",
	Group = "FeatureFlags",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "featureFlagId",
			Name = "featureFlagId",
			Description = "ID of the feature flag"
		}
	}
}