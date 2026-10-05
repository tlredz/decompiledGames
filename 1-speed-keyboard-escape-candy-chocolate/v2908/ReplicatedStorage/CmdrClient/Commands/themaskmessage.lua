return {
	Name = "themaskmessage",
	Aliases = { "maskmsg", "tmm" },
	Description = "Broadcasts a fake admin message from \"The Mask\" to all players, on all servers.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "message",
			Description = "The message text to display (quote it if it contains spaces)."
		},
		{
			Type = "number",
			Name = "duration",
			Description = "Display duration in seconds (default: 10).",
			Optional = true
		}
	}
}