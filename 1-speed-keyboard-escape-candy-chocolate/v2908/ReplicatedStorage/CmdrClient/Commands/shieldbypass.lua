return {
	Name = "shieldbypass",
	Aliases = { "ssbypass", "shieldexclude" },
	Description = "Exclude a player from SecretShield for this server session (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Description = "true = bypass shield, false = enforce shield."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}