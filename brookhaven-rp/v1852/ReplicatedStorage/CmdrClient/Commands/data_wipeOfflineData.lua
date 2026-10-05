return {
	Name = "data_wipeOfflineData",
	Aliases = {},
	Description = "Wipes all offline-writable data for a player, i.e. gifts",
	Group = "Data",
	Args = {
		{
			Type = "playerId",
			Name = "Player",
			Description = "Wipes all offline-writable data for the specified player, you can enter the user ID by placing \"#\" as the prefix (e.g. #123456789)"
		}
	}
}