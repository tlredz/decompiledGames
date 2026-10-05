return {
	Name = "announcement",
	Description = "Shows an announcement to your server.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The announcement to show."
		}
	}
}