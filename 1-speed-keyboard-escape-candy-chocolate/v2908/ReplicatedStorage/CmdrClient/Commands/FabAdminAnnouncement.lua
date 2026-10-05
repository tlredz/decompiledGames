return {
	Name = "fabannounce",
	Aliases = { "faa" },
	Description = "Shows a FabAdminAnnouncement to everyone in this server.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "message",
			Description = "The announcement text."
		},
		{
			Type = "number",
			Name = "duration",
			Description = "How long the completed message remains visible.",
			Optional = true
		}
	}
}