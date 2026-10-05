return {
	Name = "awardtitle",
	Aliases = { "give-title" },
	Description = "Grants a title to a player or set of players",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give titles to."
		},
		{
			Type = "titles",
			Name = "title",
			Description = "The titles to give to the players."
		}
	}
}