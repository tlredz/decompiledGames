return {
	Name = "spawnEventCoins",
	Aliases = { "eventcoins", "spawncoins" },
	Description = "Force-spawns N coins of the running event for each player on all servers.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "count",
			Description = "Coins each player receives."
		}
	}
}