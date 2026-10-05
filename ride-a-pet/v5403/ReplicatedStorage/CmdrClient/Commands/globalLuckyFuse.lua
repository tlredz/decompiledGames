return {
	Name = "globalluckyfuse",
	Aliases = {},
	Description = "Start Lucky Fuse globally.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "seconds",
			Description = "Duration, default 300 seconds.",
			Optional = true
		}
	}
}