return {
	Name = "performance_profilePlayer",
	Aliases = { "perf_profilePlayer" },
	Description = "Starts a profile sample for the given player.",
	Group = "GameSdkPerformance",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to start a profile sample for."
		},
		{
			Type = "number",
			Name = "durationSeconds",
			Description = "The duration of the profile sample in seconds."
		},
		{
			Type = "number",
			Name = "intervalSeconds",
			Description = "The interval of the profile sample in seconds."
		},
		{
			Type = "string",
			Name = "existingProfileId",
			Description = "The existing profile ID to add a sample to.",
			Optional = true
		}
	}
}