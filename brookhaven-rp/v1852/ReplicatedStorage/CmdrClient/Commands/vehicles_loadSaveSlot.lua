return {
	Name = "vehicles_loadSaveSlot",
	Description = "Spawns a vehicle from one of a player's saved vehicle slots.",
	Group = "Vehicles",
	Args = {
		{
			Type = "player",
			Name = "user",
			Description = "The player whose save slot to load"
		},
		{
			Type = "string",
			Name = "slotNumber",
			Description = "The save slot to load (e.g. 'v1')"
		}
	}
}