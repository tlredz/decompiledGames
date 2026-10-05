return {
	Name = "globalEarningsBoost",
	Description = "Boosts brainrot earnings in all servers.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "Multiplier",
			Description = "The multiplier to apply (1 - 16)."
		},
		{
			Type = "integer",
			Name = "Duration",
			Description = "The duration in seconds."
		}
	}
}