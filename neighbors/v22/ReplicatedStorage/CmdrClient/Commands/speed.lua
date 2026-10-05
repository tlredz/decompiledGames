return {
	Name = "speed",
	Description = "Makes a players walkspeed a new value (default: 16)",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to adjust the speed of."
		},
		{
			Type = "integer",
			Name = "walkspeed",
			Description = "The new speed for the players."
		}
	}
}