return {
	Name = "globalEggSizeBoost",
	Description = "Boosts the size of eggs spawning on the map in all servers.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "Multiplier",
			Description = "The multiplier to apply (1 - 4)."
		},
		{
			Type = "integer",
			Name = "Duration",
			Description = "The duration in seconds."
		}
	}
}