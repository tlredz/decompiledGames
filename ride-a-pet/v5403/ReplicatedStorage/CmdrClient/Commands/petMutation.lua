return {
	Name = "petmutation",
	Aliases = { "setpetmutation" },
	Description = "Set an owned pet hatch mutation; None clears it.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet ID from petinfo."
		},
		{
			Type = "petSpawnMutation",
			Name = "mutation",
			Description = "Set an owned pet hatch mutation; None clears it."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Owner in this server; defaults to you.",
			Optional = true
		}
	}
}