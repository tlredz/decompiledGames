return {
	Name = "petweather",
	Aliases = { "setpetweather" },
	Description = "Set an owned pet weather trait; None clears it.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "pet-key",
			Description = "Exact pet ID from petinfo."
		},
		{
			Type = "petWeatherTrait",
			Name = "weather",
			Description = "Set an owned pet weather trait; None clears it."
		},
		{
			Type = "player",
			Name = "player",
			Description = "Owner in this server; defaults to you.",
			Optional = true
		}
	}
}