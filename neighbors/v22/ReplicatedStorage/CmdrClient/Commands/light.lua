return {
	Name = "light",
	Aliases = { "" },
	Description = "Make a character glow",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to make glow."
		},
		{
			Type = "integer",
			Name = "size",
			Description = "size of the glow"
		},
		{
			Type = "brickColor3",
			Name = "color",
			Description = "color of the glow"
		},
		{
			Type = "integer",
			Name = "brightness",
			Description = "brightness of the glow"
		}
	}
}