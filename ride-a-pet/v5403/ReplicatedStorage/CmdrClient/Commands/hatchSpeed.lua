return {
	Name = "hatchspeed",
	Description = "Set hatch speed on this server. Replaces the previous boost.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "amount",
			Description = "Hatch speed multiplier, 1 to 5. Use 1 to restore normal speed."
		},
		{
			Type = "duration",
			Name = "time",
			Description = "Duration, e.g. 30m or 1h. Default: 10 minutes.",
			Default = 600
		}
	}
}