return {
	Name = "housing_spawnOnCurrentLot",
	Description = "Spawn a house from ServerStorage.Houses on your currently claimed lot.",
	Group = "Housing",
	Args = {
		{
			Type = "propertyId",
			Name = "propertyId",
			Description = "The property to spawn"
		}
	}
}