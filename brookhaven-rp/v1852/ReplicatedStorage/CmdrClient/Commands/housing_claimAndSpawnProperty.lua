return {
	Name = "housing_claimAndSpawnProperty",
	Description = "Spawns a property on specific lots.",
	Group = "Housing",
	Args = {
		{
			Type = "lotIds",
			Name = "lotId",
			Description = "The lot(s) to spawn the property on"
		},
		{
			Type = "propertyId",
			Name = "propertyId",
			Description = "The property to spawn"
		}
	}
}