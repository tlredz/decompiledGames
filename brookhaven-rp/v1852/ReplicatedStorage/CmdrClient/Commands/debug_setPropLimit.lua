return {
	Name = "debug_setPropLimit",
	Aliases = { "prop_setDebugLimit" },
	Description = "Override this server's prop limit for testing. Omit the limit to clear the override.",
	Group = "Debug",
	Args = {
		{
			Type = "integer",
			Name = "limit",
			Description = "Prop limit to apply. Omit to clear the override.",
			Optional = true
		}
	}
}