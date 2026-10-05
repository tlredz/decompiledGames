return {
	Name = "cc_fly",
	Aliases = {},
	Description = "Make a player fly",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will be made to fly",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether to enable or disable flying",
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