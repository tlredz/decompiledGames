return {
	Name = "spawnpet",
	Aliases = { "givepet" },
	Description = "Grants a saved pet to a player's inventory or base in this server.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "petName",
			Name = "pet",
			Description = "Pet species. Quote names containing spaces."
		},
		{
			Type = "petSpawnMutation",
			Name = "mutation",
			Description = "Hatch mutation: Gold, Diamond, Rainbow, or None.",
			Default = "None"
		},
		{
			Type = "petWeatherTrait",
			Name = "weather",
			Description = "Weather trait such as Volted, or storm name such as Volt. None for plain.",
			Default = "None"
		},
		{
			Type = "number",
			Name = "size",
			Description = "Current size multiplier: 1 is normal, 2 is double, at the chosen age. Past 4x bounces with a double warning until you run the same command again.",
			Default = 1
		},
		{
			Type = "integer",
			Name = "age",
			Description = "Age from 1 to the game's maximum age (currently 100).",
			Default = 1
		},
		{
			Type = "petDestination",
			Name = "destination",
			Description = "inventory or base. Base placement respects available ranch slots.",
			Default = "inventory"
		},
		{
			Type = "player",
			Name = "player",
			Description = "Player in this server; defaults to yourself.",
			Optional = true
		},
		{
			Type = "integer",
			Name = "amount",
			Description = "Number of identical pets to grant, from 1 to 25.",
			Default = 1
		}
	}
}