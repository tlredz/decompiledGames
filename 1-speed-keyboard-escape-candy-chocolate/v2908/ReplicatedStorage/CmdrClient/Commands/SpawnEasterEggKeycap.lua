return {
	Name = "spawnEasterEggKeycap",
	Aliases = { "eastereggkeycap", "spawnkeycapegg" },
	Description = "Lists Easter-Egg types, or force-spawns the selected type near you.",
	Group = "Debug",
	Args = {
		{
			Type = "string",
			Name = "type",
			Description = "Easter-Egg event type. Omit to list available types.",
			Optional = true
		}
	}
}