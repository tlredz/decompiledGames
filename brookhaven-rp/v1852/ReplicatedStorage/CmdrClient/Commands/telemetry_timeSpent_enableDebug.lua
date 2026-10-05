return {
	Name = "telemetry_timeSpent_enableDebug",
	Aliases = {},
	Description = "Enables debug mode for the time spent telemetry, which will print debug information to the output and color the boxes that you enter.",
	Group = "Telemetry",
	Args = {
		{
			Type = "boolean",
			Name = "enable",
			Description = "Whether to enable debug mode or not."
		}
	}
}