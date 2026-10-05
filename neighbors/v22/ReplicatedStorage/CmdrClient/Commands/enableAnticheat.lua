return {
	Name = "enableanticheat",
	Aliases = { "" },
	Description = "Enables a player or set of players anticheat",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to enable anticheat for."
		}
	}
}