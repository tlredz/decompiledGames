return {
	Name = "cc_setOnFire",
	Aliases = {},
	Description = "Toggle a fire effect on players' characters",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players who will be set on fire or extinguished",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether to enable the fire effect",
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