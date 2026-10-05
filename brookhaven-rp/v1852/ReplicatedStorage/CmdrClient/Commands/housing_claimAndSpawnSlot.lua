return {
	Name = "housing_claimAndSpawnSlot",
	Description = "Claims a lot for a player and spawns the property and props from one of their saved house slots.",
	Group = "Housing",
	Args = {
		{
			Type = "player",
			Name = "user",
			Description = "The player whose save slot to use and who will own the lot"
		},
		{
			Type = "lotId",
			Name = "plotNumber",
			Description = "The lot to claim and spawn the property on"
		},
		{
			Type = "string",
			Name = "slotNumber",
			Description = "The save slot to load (e.g. 'h1')"
		}
	}
}