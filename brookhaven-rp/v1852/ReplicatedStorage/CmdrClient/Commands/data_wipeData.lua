return {
	Name = "data_wipeData",
	Aliases = {},
	Description = "Wipes all data for a player",
	Group = "Data",
	Args = {
		{
			Type = "playerId",
			Name = "Player",
			Description = "Wipes all data for the specified player, you can enter the user ID by placing \"#\" as the prefix (e.g. #123456789)"
		}
	}
}