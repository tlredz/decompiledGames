return {
	Name = "goto-player",
	Aliases = { "join-player" },
	Description = "Join a player's server by Roblox username.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Username",
			Description = "The player's Roblox username"
		}
	}
}