return {
	Name = "view",
	Aliases = { "spectate", "spec", "watch" },
	Description = "Spectate a player",
	Group = "Moderator",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "player to spectate"
		}
	}
}