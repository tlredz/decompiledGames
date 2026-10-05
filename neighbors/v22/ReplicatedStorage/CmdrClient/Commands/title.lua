return {
	Name = "title",
	Aliases = {},
	Description = "Sets the title of a player or set of players.",
	Group = "CommunityManager",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to set the title of."
		},
		{
			Type = "title",
			Name = "title",
			Description = "The new title to give players."
		}
	}
}