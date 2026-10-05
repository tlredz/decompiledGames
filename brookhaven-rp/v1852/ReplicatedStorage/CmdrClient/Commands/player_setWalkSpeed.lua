return {
	Name = "player_setWalkSpeed",
	Aliases = { "ws", "walkspeed" },
	Description = "Set the walk speed of a player",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player that will have the walk speed updated",
			Optional = false
		},
		{
			Type = "number",
			Name = "speed",
			Description = "The new walk speed for the player",
			Optional = false
		}
	}
}