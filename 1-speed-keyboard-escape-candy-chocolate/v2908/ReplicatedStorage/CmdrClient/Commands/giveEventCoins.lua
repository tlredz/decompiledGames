return {
	Name = "giveEventCoins",
	Aliases = { "giveeventcoins", "giveeventcoin" },
	Description = "Give N of the running event's currency to every online player on all servers (currency grant, not world spawns).",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "amount",
			Description = "Event currency each player receives."
		}
	}
}