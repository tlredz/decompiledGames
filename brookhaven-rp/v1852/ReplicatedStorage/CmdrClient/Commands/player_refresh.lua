return {
	Name = "player_refresh",
	Aliases = { "respawn", "re" },
	Description = "Respawns the player and returns them to their previous location.",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to be refreshed",
			Optional = true
		}
	}
}