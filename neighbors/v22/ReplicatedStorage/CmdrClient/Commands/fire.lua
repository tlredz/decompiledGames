return {
	Name = "fire",
	Aliases = { "fire" },
	Description = "Lights a players head on fire",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to ignite."
		},
		{
			Type = "brickColor3",
			Name = "Color",
			Description = "The color of the fire"
		},
		{
			Type = "integer",
			Name = "Size",
			Description = "Size (1-30)"
		}
	}
}