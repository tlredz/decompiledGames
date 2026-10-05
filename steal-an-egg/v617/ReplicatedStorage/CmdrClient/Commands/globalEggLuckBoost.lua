return {
	Name = "globalEggLuckBoost",
	Description = "Boosts egg spawn luck on the map in all servers.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "Multiplier",
			Description = "The multiplier to apply (1 - 100)."
		},
		{
			Type = "integer",
			Name = "Duration",
			Description = "The duration in seconds."
		}
	}
}