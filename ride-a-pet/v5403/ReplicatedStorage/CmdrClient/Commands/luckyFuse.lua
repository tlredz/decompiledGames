return {
	Name = "luckyfuse",
	Aliases = {},
	Description = "Start Lucky Fuse on this server.",
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