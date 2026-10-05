return {
	Name = "unwarn",
	Description = "Unwarns a player in the game",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "player to unwarn"
		},
		{
			Type = "integer",
			Name = "index",
			Description = "index of warn"
		}
	}
}