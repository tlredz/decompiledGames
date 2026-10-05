return {
	Name = "world_setTimeOfDay",
	Aliases = {},
	Description = "Set the Time of Day to a specific time",
	Group = "World",
	Args = {
		{
			Type = "number",
			Name = "hours",
			Description = "Hour of the day (0-11)"
		},
		{
			Type = "number",
			Name = "minutes",
			Description = "Minute of the hour (0-59)"
		},
		{
			Type = "string",
			Name = "AM or PM",
			Description = "AM or PM"
		}
	}
}