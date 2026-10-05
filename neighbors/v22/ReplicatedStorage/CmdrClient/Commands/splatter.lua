return {
	Name = "splatter",
	Aliases = { "splatter" },
	Description = "Splatter a player's screen with the tomato effect of a chosen color",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to splatter."
		},
		{
			Type = "brickColor3",
			Name = "Color",
			Description = "The color of the splatter effect"
		},
		{
			Type = "integer",
			Name = "Count",
			Description = "The count of splatters"
		}
	}
}