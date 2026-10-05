return {
	Name = "volcanicegg",
	Aliases = { "spawnvolcanic" },
	Description = "Forces the Volcanic Egg onto its own pad on THIS server, even while the pad is cooling down. The volcano has to be revealed. Weight, mutations and timer are optional.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "weight",
			Description = "Size multiplier in KG, up to 5. Omit for the normal random roll, or type \"\" to skip it when you need the arguments after it. Big ones bounce with a warning until you run the same command again.",
			Optional = true
		},
		{
			Type = "eggMutations",
			Name = "mutations",
			Description = "Comma-separated, one weather + one spawned - e.g. Shocked,Gold. Omit or None for plain.",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "timer",
			Description = "Whether the egg goes on the break clock when it is picked up. Omit for true; false means it never breaks in a basket.",
			Default = true
		}
	}
}