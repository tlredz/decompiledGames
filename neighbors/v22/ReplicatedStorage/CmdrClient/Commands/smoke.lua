return {
	Name = "smoke",
	Aliases = {},
	Description = "Makes a player start smoking",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to set smoke upon."
		},
		{
			Type = "integer",
			Name = "Size",
			Description = "Size number"
		},
		{
			Type = "brickColor3",
			Name = "Color",
			Description = "The color of the smoke"
		}
	}
}