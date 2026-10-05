return {
	Name = "servershout",
	Aliases = { "shout" },
	Description = "Announces a message only in this server.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "text",
			Description = "The announcement text."
		}
	}
}