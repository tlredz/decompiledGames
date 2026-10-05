return {
	Name = "globalAnnouncement",
	Description = "Shows a global announcement.",
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