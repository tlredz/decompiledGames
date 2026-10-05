return {
	Name = "profiling_logStatsToDatastoreAndDiscord",
	Aliases = {},
	Description = "Logs the memory of the target player to datastore and then sends that through a webhook to discord.",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to record memory from."
		},
		{
			Type = "number",
			Name = "durationSeconds",
			Description = "The duration of the memory log in seconds."
		}
	}
}