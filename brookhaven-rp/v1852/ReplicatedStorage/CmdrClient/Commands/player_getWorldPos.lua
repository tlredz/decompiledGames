return {
	Name = "player_getWorldPos",
	Aliases = {},
	Description = "Outputs the player current world position",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to get world coordinates of",
			Optional = true
		}
	}
}