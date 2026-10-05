return {
	Name = "player_unlockHouse",
	Aliases = {},
	Description = "Unlock a house for a player",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "houseFeature",
			Name = "Feature",
			Description = "Name of the house to unlock"
		}
	}
}