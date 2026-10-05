return {
	Name = "weather",
	Aliases = { "storm", "spawnweather" },
	Description = "Forces a storm of the chosen variant on THIS server. Expires on its own.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "stormVariant",
			Name = "variant",
			Description = "Thunder, Volt, Raging, Dreadful or Eternal (the mutation name works too: Volted, Void...)."
		},
		{
			Type = "number",
			Name = "seconds",
			Description = "How long the storm lasts. Defaults to a natural storm's length (300s). Capped at 3600.",
			Optional = true
		}
	}
}