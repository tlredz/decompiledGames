return {
	Name = "housing_spawnHouse",
	Aliases = { "spawnHouse" },
	Description = "Finds an available lot, spawns the given house on it, and teleports you there.",
	Group = "Housing",
	Args = {
		{
			Type = "propertyId",
			Name = "id",
			Description = "The house/property to spawn"
		}
	}
}