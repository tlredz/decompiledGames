return {
	Name = "cc_explode",
	Aliases = {},
	Description = "Explode a player",
	Group = "ContentCreators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will be exploded",
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