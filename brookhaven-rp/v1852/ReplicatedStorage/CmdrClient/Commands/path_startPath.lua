return {
	Name = "path_startPath",
	Description = "Start playback of a path for the given player.",
	Group = "GameSdkPathing",
	Args = {
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "The player to play back the path for."
		},
		{
			Type = "pathName",
			Name = "pathName",
			Description = "The name of the path to play back."
		}
	}
}