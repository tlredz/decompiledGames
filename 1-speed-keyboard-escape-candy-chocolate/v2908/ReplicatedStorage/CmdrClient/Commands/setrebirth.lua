return {
	Name = "setrebirth",
	Aliases = { "sr" },
	Description = "Sets a player's rebirth count (0–max). Also updates their multiplier. Default: yourself.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "rebirths",
			Description = "Rebirth count (0 = no rebirth, clamped to max tier)."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Player to update (default: you).",
			Optional = true
		}
	}
}