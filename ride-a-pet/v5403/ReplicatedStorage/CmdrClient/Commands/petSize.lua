return {
	Name = "petsize",
	Aliases = { "setpetsize" },
	Description = "Set current size: 1 is normal, 2 is double. Preserves age and level progress.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet ID from petinfo."
		},
		{
			Type = "number",
			Name = "size",
			Description = "Set current size: 1 is normal, 2 is double. Preserves age and level progress. Past 4x bounces with a double warning until you run the same command again."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Owner in this server; defaults to you.",
			Optional = true
		}
	}
}