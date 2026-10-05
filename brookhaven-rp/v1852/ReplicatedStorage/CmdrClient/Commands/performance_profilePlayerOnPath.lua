return {
	Name = "performance_profilePlayerOnPath",
	Aliases = { "perf_profilePlayerOnPath" },
	Description = "Starts a profile sample for the given player while replaying a saved path.",
	Group = "GameSdkPerformance",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to start a profile sample for."
		},
		{
			Type = "pathName",
			Name = "pathName",
			Description = "The name of the path to replay."
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