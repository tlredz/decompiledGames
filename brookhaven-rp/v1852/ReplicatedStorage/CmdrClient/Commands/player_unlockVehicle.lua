return {
	Name = "player_unlockVehicleId",
	Aliases = {},
	Description = "Set the unlock state of a vehicle for a target player.",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "Target Player",
			Description = "Target player to unlock vehicle for."
		},
		{
			Type = "unlockableVehicleId",
			Name = "Vehicle Id",
			Description = "Id of the vehicle to unlock."
		},
		{
			Type = "boolean",
			Name = "Unlock State",
			Description = "State to set the vehicle to."
		}
	}
}