return {
	Name = "globalStartEvent",
	Description = "Start an event in all servers",
	Group = "Moderator",
	Args = {
		{
			Type = "adminStartEventType",
			Name = "Event Name"
		},
		{
			Type = "number",
			Name = "Duration"
		}
	}
}