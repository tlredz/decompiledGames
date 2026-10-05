return {
	Name = "resetShrineFusion",
	Description = "Clear a player's once-per-account Divine/Eternal shrine fusion so it can be run again.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to reset."
		},
		{
			Type = "shrineFusionTier",
			Name = "Tier",
			Description = "Divine, Eternal, or Both.",
			Default = "Both",
			Optional = true
		}
	}
}