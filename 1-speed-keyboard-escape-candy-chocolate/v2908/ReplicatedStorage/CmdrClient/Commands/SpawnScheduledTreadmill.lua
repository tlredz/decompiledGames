return {
	Name = "SpawnScheduledTreadmill",
	Aliases = { "sst" },
	Description = "Force-spawn a scheduled treadmill now. Valid names: Hourly, Daily.",
	Group = "Debug",
	Args = {
		{
			Type = "scheduledTreadmill",
			Name = "name",
			Description = "Scheduled treadmill name: Hourly or Daily."
		}
	}
}