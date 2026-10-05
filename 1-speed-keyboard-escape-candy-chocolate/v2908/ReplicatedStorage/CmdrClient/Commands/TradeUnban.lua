return {
	Name = "tradeunban",
	Aliases = { "tunban" },
	Description = "Allow an online trade-banned player to trade again.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to trade-unban."
		}
	}
}