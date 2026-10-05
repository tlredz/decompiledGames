return {
	Name = "scramblePity",
	Aliases = { "labPity" },
	Description = "Set a player's Dr. Scramble laboratory pity count. Use one below the threshold to guarantee the next roll.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "Players to update (use me for yourself)."
		},
		{
			Type = "integer",
			Name = "Count",
			Description = "Completed rolls since the last top reward. Use 199 for a guaranteed next roll at a 200-roll threshold."
		},
		{
			Type = "string",
			Name = "Banner",
			Description = "current, Biohazard, Experimental, or UnstableDNA.",
			Optional = true,
			Default = "current"
		}
	}
}