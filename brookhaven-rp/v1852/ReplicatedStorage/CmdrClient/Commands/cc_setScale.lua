return {
	Name = "cc_setScale",
	Aliases = {},
	Description = "Set the scale of a player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will have their scale set",
			Optional = false
		},
		{
			Type = "number",
			Name = "scale",
			Description = "The scale to set",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before exploding the player",
			Optional = true
		}
	}
}