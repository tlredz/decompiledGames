return {
	Name = "cc_setBigHead",
	Aliases = {},
	Description = "Toggle an oversized head on players (R15)",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players whose head scale will change",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether to enable big head",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before applying",
			Optional = true
		}
	}
}