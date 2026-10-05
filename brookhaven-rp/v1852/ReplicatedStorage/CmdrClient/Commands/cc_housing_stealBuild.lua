return {
	Name = "cc_housing_stealBuild",
	Aliases = {},
	Description = "Load a player's house save state onto your lot",
	Group = "Housing",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "houseSaveSlot",
			Name = "slot",
			Description = "house save slot"
		},
		{
			Type = "string",
			Name = "version",
			Description = "profile version",
			Optional = true
		}
	}
}