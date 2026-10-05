return {
	Name = "sendToCreator",
	Description = "Teleports players into a creator's reserved server.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to send."
		},
		{
			Type = "string",
			Name = "Server",
			Description = "The owner's UserId, or the CC_ server key."
		}
	}
}