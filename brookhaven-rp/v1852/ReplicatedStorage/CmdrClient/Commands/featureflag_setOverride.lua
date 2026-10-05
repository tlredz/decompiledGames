return {
	Name = "featureflag_setOverride",
	Aliases = {},
	Description = "Override a feature flag for a player",
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
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "true to enable the feature flag for the player, false to disable it"
		}
	}
}