return {
	Name = "globalspawnegg",
	Aliases = { "gspawnegg", "gegg" },
	Description = "Spawns the same egg on EVERY server, each on its own rarity-appropriate pad.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "eggName",
			Name = "egg",
			Description = "Which egg. Quote names with spaces, or just type part of one."
		},
		{
			Type = "number",
			Name = "weight",
			Description = "Size multiplier in KG, up to 5. Omit and one roll is made here (Ethereals roll 1 to 1.5), then shared with every server. Type \"\" to skip it when you need the arguments after it. Big ones bounce with a warning until you run the same command again.",
			Optional = true
		},
		{
			Type = "eggMutations",
			Name = "mutations",
			Description = "Comma-separated, one weather + one spawned - Shocked, Volted, Rage, Void, Eternal, Gold, Diamond, Rainbow. E.g. Shocked,Gold. Omit or None for plain.",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "timer",
			Description = "Whether the egg goes on the break clock when it is picked up, on every server. Omit for true; false means it never breaks in a basket.",
			Default = true
		}
	}
}