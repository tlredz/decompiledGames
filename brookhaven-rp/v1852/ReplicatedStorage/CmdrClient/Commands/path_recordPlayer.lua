return {
	Name = "path_recordPlayer",
	Description = "Records a new path for the given player.",
	Group = "GameSdkPathing",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to record a path for."
		},
		{
			Type = "string",
			Name = "pathName",
			Description = "The name of the path to create."
		},
		{
			Type = "number",
			Name = "durationSeconds",
			Description = "The duration of the path in seconds."
		},
		{
			Type = "number",
			Name = "intervalSeconds",
			Description = "The interval of the path in seconds."
		}
	}
}