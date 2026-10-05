return {
	Name = "replica_track",
	Aliases = {},
	Description = "Tracks a single player for cross-server character replication. Omit the player to stop tracking.",
	Group = "Debug",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to track, or nothing to stop tracking",
			Optional = true
		}
	}
}