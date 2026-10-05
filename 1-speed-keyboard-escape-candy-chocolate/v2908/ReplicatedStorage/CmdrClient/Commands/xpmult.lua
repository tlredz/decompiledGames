return {
	Name = "xpmult",
	Aliases = { "xpm" },
	Description = "Override the test-place XP multiplier for this session. 1 = normal, 10000000 = full test-place rate.",
	Group = "Debug",
	Args = {
		{
			Type = "number",
			Name = "multiplier",
			Description = "New ConfigXPMultiplier value (e.g. 1, 10, 10000000)."
		}
	}
}