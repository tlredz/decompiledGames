return {
	Name = "joinprivateserver",
	Aliases = { "" },
	Description = "Sends a player or set of players to a private server.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to teleport."
		}
	}
}