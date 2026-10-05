return {
	Name = "privatemessage",
	Aliases = { "pm" },
	Description = "Sends a private message to a player.",
	Group = "Moderator",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to send the message to."
		},
		{
			Type = "string",
			Name = "text",
			Description = "The announcement text."
		}
	}
}