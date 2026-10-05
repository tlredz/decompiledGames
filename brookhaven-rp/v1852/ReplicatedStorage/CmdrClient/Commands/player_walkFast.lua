return {
	Name = "player_walkFast",
	Aliases = { "fast" },
	Description = "Set the walk speed of a player to fast",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player that will have the walk speed set to fast",
			Optional = true
		}
	}
}