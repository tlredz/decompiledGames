return {
	Name = "utility_teleportPos",
	Aliases = {},
	Description = "Teleports player(s) to a specific position",
	Group = "Utility",
	Args = {
		{
			Type = "players",
			Name = "player",
			Description = "Player(s) to teleport"
		},
		{
			Type = "vector3",
			Name = "position",
			Description = "Position to teleport to"
		}
	}
}