return {
	Name = "scrambleRotate",
	Aliases = { "labRotate" },
	Description = "Rotate this server's Dr. Scramble laboratory banner now and restart its one-hour timer.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Banner",
			Description = "next (weighted), Biohazard, Experimental, or UnstableDNA.",
			Optional = true,
			Default = "next"
		}
	}
}