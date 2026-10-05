return {
	Name = "player_kick",
	Aliases = {},
	Description = "Kicks a player from the game",
	Group = "Player",
	Args = {
		{
			Type = "string",
			Name = "username",
			Description = "Username of the player that will be kicked"
		},
		{
			Type = "string",
			Name = "reason",
			Description = "Reason for the kick",
			Optional = true
		}
	}
}