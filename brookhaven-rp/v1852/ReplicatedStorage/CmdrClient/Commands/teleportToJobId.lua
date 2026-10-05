return {
	Name = "teleportToJobId",
	Aliases = {},
	Description = "Teleports a player to a server",
	Group = "Utility",
	Args = {
		{
			Type = "players",
			Name = "player",
			Description = "Player(s) to teleport"
		},
		{
			Type = "string",
			Name = "serverId",
			Description = "Server to teleport to"
		}
	}
}