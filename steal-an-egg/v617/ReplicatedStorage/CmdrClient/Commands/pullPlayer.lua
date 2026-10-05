return {
	Name = "pullPlayer",
	Description = "Teleports a player from another server in this game into your server.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Username",
			Description = "The player's full username."
		}
	}
}