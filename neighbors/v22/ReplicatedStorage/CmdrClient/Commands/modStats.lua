return {
	Name = "modstats",
	Description = "Checks mod stats of a player",
	Group = "SeniorModerator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "moderator userId"
		},
		{
			Type = "duration",
			Name = "duration",
			Description = "duration of ban",
			Optional = true
		}
	}
}