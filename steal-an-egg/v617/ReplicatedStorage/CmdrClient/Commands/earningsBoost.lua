return {
	Name = "earningsBoost",
	Description = "Gives the player the x2 earnings boost. Duration 0 clears it.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to boost."
		},
		{
			Type = "integer",
			Name = "DurationSeconds",
			Description = "Seconds to add (default 900). 0 clears the boost.",
			Optional = true
		}
	}
}