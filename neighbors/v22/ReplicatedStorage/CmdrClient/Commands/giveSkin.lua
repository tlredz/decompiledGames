return {
	Name = "awardskin",
	Aliases = { "give-skin" },
	Description = "Awards a player or set of players a skin or multiple skins",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give tools to."
		},
		{
			Type = "skins",
			Name = "skins",
			Description = "The skin(s) to give to the players."
		}
	}
}