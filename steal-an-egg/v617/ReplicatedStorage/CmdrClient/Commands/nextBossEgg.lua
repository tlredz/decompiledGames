return {
	Name = "nextBossEgg",
	Aliases = { "scrambleBossEgg" },
	Description = "Guarantee one Mecha Scrambler egg on each selected player's next eligible boss defeat in this server, including admin fights.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "Players to arm. Defaults to you; use all for current players.",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Enabled",
			Description = "False cancels the pending guarantee. Defaults to true.",
			Optional = true
		}
	}
}