return {
	Name = "givenametag",
	Aliases = { "nametag" },
	Description = "Give Name Tag gears (one-time pet rename).",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Who gets them; defaults to you.",
			Optional = true
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "How many to give (1-100); defaults to 1.",
			Optional = true
		}
	}
}