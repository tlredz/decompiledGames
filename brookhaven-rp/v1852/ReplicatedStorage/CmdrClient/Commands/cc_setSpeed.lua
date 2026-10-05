return {
	Name = "cc_setSpeed",
	Aliases = {},
	Description = "Set the speed of a player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will have their speed set",
			Optional = false
		},
		{
			Type = "number",
			Name = "speed",
			Description = "The speed to set",
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