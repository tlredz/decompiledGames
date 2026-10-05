return {
	Name = "player_unban",
	Aliases = {},
	Description = "Unbans a player from the game",
	Group = "Player",
	Args = {
		{
			Type = "string",
			Name = "player",
			Description = "Player that will be unbanned"
		}
	}
}