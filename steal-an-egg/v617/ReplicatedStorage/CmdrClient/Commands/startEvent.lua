return {
	Name = "startEvent",
	Description = "Start an event",
	Group = "Moderator",
	Args = {
		{
			Type = "adminStartEventType",
			Name = "Event Name"
		},
		{
			Type = "number",
			Name = "Duration"
		},
		{
			Type = "boolean",
			Name = "Skip Cutscenes",
			Description = "Optional Argument to skip the cutscene (where supported)",
			Optional = true
		}
	}
}