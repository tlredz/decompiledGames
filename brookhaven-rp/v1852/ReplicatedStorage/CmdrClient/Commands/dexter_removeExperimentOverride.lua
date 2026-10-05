return {
	Name = "dexter_removeExperimentOverride",
	Description = "Remove a player's overridden variant for supplied experiment.",
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
			Description = "The experiment name to remove override for"
		}
	}
}