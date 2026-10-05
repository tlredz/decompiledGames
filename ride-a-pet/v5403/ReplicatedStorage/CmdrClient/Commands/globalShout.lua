return {
	Name = "globalshout",
	Aliases = { "m" },
	Description = "Makes a global-wide announcement.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "text",
			Description = "The announcement text."
		}
	}
}