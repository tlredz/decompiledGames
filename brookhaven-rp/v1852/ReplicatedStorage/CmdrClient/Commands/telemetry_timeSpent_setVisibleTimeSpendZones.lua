return {
	Name = "telemetry_timeSpent_setVisibleTimeSpendZones",
	Aliases = {},
	Description = "Toggles the visibility of the time spent telemetry zones.",
	Group = "Telemetry",
	Args = {
		{
			Type = "boolean",
			Name = "visible",
			Description = "Whether to make the zones visible or not."
		}
	}
}