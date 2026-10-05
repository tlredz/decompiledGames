return {
	Name = "jumppower",
	Description = "Sets the jump power of a player.",
	Aliases = { "jp" },
	Group = "Tester",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to change the jump power of"
		},
		{
			Type = "number",
			Name = "power",
			Description = "The jumppower value to set"
		}
	}
}