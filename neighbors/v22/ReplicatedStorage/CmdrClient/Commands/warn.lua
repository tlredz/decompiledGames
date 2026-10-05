return {
	Name = "warn",
	Description = "Warns a player in the game",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "player to warn"
		},
		{
			Type = "string",
			Name = "reason",
			Description = "reason for warn"
		}
	}
}