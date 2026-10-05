return {
	Name = "name",
	Aliases = { "" },
	Description = "Sets a player or set of players name to a string.",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to change names for."
		},
		{
			Type = "string",
			Name = "name",
			Description = "The new name for the players"
		}
	}
}