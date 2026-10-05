return {
	Name = "announce",
	Aliases = { "m" },
	Description = "Makes a server-wide announcement.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "text",
			Description = "The announcement text."
		}
	}
}