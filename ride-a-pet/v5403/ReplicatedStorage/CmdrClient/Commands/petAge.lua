return {
	Name = "petage",
	Aliases = { "setpetage" },
	Description = "Set age from 1 to 100. Keeps birth size and applies normal age growth; resets level progress.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet ID from petinfo."
		},
		{
			Type = "integer",
			Name = "age",
			Description = "Set age from 1 to 100. Keeps birth size and applies normal age growth; resets level progress."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Owner in this server; defaults to you.",
			Optional = true
		}
	}
}