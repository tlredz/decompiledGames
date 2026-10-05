return {
	Name = "followplayer",
	Aliases = { "" },
	Description = "Joins a player's server on Neighbors",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "playerId",
			Description = "The player to join."
		}
	}
}