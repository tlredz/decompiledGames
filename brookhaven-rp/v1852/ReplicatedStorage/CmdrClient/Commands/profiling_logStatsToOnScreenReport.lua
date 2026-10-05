return {
	Name = "profiling_logStatsToOnScreenReport",
	Aliases = {},
	Description = "Logs the stats of the target player to a on screen report",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to record stats from."
		},
		{
			Type = "number",
			Name = "durationSeconds",
			Description = "The duration of the stats log in seconds."
		}
	}
}