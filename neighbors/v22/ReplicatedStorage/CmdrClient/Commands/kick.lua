return {
	Name = "kick",
	Aliases = { "boot" },
	Description = "Kicks a player",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "The player to kick."
		}
	}
}