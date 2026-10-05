return {
	Name = "cc_setInvisible",
	Aliases = {},
	Description = "Make players' characters invisible or visible",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players whose character visibility will change",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether to make characters invisible",
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