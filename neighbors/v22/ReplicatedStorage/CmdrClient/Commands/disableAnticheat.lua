return {
	Name = "disableanticheat",
	Aliases = { "" },
	Description = "Disables a player or set of players anticheat",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to disable anticheat for."
		}
	}
}