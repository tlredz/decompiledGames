return {
	Name = "profiling_logMemoryToDiscord",
	Aliases = {},
	Description = "Logs the memory of the target player to a discord webhook",
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