return {
	Name = "ban",
	Description = "Bans a player from the game",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "player to ban"
		},
		{
			Type = "duration",
			Name = "duration",
			Description = "duration of ban"
		},
		{
			Type = "string",
			Name = "displayreason",
			Description = "The reason to show the user for their ban"
		},
		{
			Type = "string",
			Name = "privatereason",
			Description = "Internal reason",
			Optional = true
		}
	}
}