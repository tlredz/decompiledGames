return {
	Name = "kill",
	Aliases = {},
	Description = "Players to kill",
	Group = "Contractor",
	Blacklist = { "Influencer", "ContentManager", "VIP" },
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to kill."
		}
	}
}