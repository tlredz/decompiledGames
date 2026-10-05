return {
	Name = script.Name,
	Aliases = {},
	Description = "Teleport a player to the next contextual upsell (or to a specific 1-based index)",
	Group = "Vehicles",
	Args = {
		{
			Type = "number",
			Name = "index",
			Description = "Optional 1-based index of the contextual upsell to teleport to (wraps around). Omit to advance to the next one.",
			Optional = true
		}
	}
}