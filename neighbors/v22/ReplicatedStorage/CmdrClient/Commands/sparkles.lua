return {
	Name = "sparkles",
	Aliases = {},
	Description = "Makes a player emit sparkles",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to spark."
		},
		{
			Type = "brickColor3",
			Name = "Color",
			Description = "The color of the sparkles"
		}
	}
}