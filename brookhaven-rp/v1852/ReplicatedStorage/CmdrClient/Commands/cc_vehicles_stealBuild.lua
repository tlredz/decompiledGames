return {
	Name = "cc_vehicles_stealBuild",
	Aliases = {},
	Description = "Load a player's vehicle save state",
	Group = "Vehicles",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "vehicleSaveSlot",
			Name = "slot",
			Description = "vehicle save slot"
		},
		{
			Type = "string",
			Name = "version",
			Description = "profile version",
			Optional = true
		}
	}
}