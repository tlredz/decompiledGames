return {
	Name = "completeIndex",
	Description = "Discovers every pet an index section needs, without claiming any reward.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to fill the index for."
		},
		{
			Type = "indexSection",
			Name = "Section",
			Description = "Which index section to fill. Defaults to every section.",
			Optional = true
		}
	}
}