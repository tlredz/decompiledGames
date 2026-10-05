return {
	Name = "freeze",
	Aliases = { "" },
	Description = "Make the player freeze in place",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to freeze."
		}
	}
}