return {
	Name = "petinfo",
	Aliases = { "listpets" },
	Description = "Inspects saved inventory and base pets, including keys, mutations, size, age and weight.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player in this server; defaults to yourself.",
			Optional = true
		},
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet key from spawnpet, or all to list owned pets.",
			Default = "all"
		},
		{
			Type = "integer",
			Name = "page",
			Description = "Page of results, ten pets per page.",
			Default = 1
		}
	}
}