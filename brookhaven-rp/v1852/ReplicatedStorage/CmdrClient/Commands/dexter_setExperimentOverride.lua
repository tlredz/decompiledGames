return {
	Name = "dexter_setExperimentOverride",
	Description = "Overrides a player's variant for supplied experiment.",
	Group = "Experimentation",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to override an experiment for"
		},
		{
			Type = "string",
			Name = "experimentName",
			Description = "The experiment name to override a player's variant for"
		},
		{
			Type = "string",
			Name = "variantName",
			Description = "The target variant name"
		}
	}
}