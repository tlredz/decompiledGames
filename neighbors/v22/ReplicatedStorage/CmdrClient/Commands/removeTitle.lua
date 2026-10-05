return {
	Name = "removetitle",
	Aliases = { "remove-title" },
	Description = "Removes a title from a player or set of players",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to take titles from."
		},
		{
			Type = "titles",
			Name = "title",
			Description = "The titles to take from the players."
		}
	}
}