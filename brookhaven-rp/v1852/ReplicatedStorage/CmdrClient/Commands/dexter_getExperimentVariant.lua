return {
	Name = "dexter_getExperimentVariant",
	Description = "Gets a player dexter experiment variant.",
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
		}
	}
}