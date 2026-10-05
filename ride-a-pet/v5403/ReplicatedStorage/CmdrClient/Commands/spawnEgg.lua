return {
	Name = "spawnegg",
	Aliases = { "egg" },
	Description = "Spawns an egg on the ground in front of you. Weight, mutations and timer are optional.",
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
			Description = "Size multiplier in KG, up to 5. Omit for the normal random roll (about 0.9 to 2; Ethereals roll 1 to 1.5), or type \"\" to skip it when you need the arguments after it. Big ones bounce with a warning until you run the same command again.",
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
			Description = "Whether the egg goes on the break clock when it is picked up. Omit for true; false means it never breaks in a basket.",
			Default = true
		}
	}
}