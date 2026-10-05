return {
	Name = "telemetry_enableLogging",
	Aliases = {},
	Description = "Enable or disable logging on server side.",
	Group = "Telemetry",
	Args = {
		{
			Type = "boolean",
			Name = "enable",
			Description = "Enable or disable logging",
			Default = true,
			Optional = true
		}
	}
}