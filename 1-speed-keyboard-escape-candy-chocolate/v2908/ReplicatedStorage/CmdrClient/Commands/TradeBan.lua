return {
	Name = "tradeban",
	Aliases = { "tban" },
	Description = "Prevent an online player from trading.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to trade-ban."
		}
	}
}