return {
	Name = script.Name,
	Aliases = {},
	Description = "Spawn a vehicle for a player",
	Group = "Vehicles",
	Args = {
		{
			Type = "vehicleId",
			Name = "vehicle",
			Description = "Name of the vehicle"
		},
		{
			Type = "boolean",
			Name = "legacy",
			Default = false,
			Description = "Whether to use the legacy system"
		}
	}
}