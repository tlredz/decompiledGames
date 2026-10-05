return {
	Name = "NextScheduledTreadmill",
	Aliases = { "nst" },
	Description = "Get the number of seconds until a scheduled treadmill next spawns. Valid names: Hourly, Daily.",
	Group = "Debug",
	Args = {
		{
			Type = "scheduledTreadmill",
			Name = "name",
			Description = "Scheduled treadmill name: Hourly or Daily."
		}
	}
}