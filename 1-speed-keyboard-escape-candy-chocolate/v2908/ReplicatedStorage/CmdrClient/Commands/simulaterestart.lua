return {
	Name = "simulaterestart",
	Aliases = { "srs", "restartnotify" },
	Description = "Simulates game.ServerRestartScheduled for testing restart warnings.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "minutesUntil",
			Description = "Minutes until simulated restart (default: 60).",
			Optional = true
		},
		{
			Type = "string",
			Name = "message",
			Description = "Optional custom message (attributes.message).",
			Optional = true
		}
	}
}