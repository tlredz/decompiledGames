return {
	Name = "globalScheduleEvent",
	Description = "Schedules an event in all servers",
	Group = "Moderator",
	Args = {
		{
			Type = "adminEventType",
			Name = "Event Name"
		},
		{
			Type = "number",
			Name = "Duration"
		},
		{
			Type = "integer",
			Name = "UnixTimestamp"
		}
	}
}