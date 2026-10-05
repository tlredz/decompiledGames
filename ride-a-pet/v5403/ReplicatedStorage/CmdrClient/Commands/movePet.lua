return {
	Name = "movepet",
	Aliases = { "petmove" },
	Description = "Move an owned pet to base or inventory, preserving its identity and stats.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet ID from petinfo."
		},
		{
			Type = "petDestination",
			Name = "destination",
			Description = "Move an owned pet to base or inventory, preserving its identity and stats."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Owner in this server; defaults to you.",
			Optional = true
		}
	}
}