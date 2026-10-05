return {
	Name = "unfreeze",
	Aliases = { "" },
	Description = "Make the player unfreeze",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to unfreeze."
		}
	}
}