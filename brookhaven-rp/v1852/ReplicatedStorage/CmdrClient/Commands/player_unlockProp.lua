return {
	Name = "player_unlockProp",
	Aliases = {},
	Description = "Unlock a feature for a player",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "propFeature",
			Name = "Feature",
			Description = "Name of the feature to unlock"
		}
	}
}