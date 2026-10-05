return {
	Name = "liveEventFlag",
	Description = "Sets a live event flag in every server. Written from this server; live servers pick it up within seconds and new servers read it on startup.",
	Group = "Admin",
	Args = {
		{
			Type = "liveEventFlagName",
			Name = "Flag",
			Description = "The flag to change."
		},
		{
			Type = "liveEventFlagAction",
			Name = "Action",
			Description = "set, schedule, reset (back to the default), or status."
		},
		{
			Type = "string",
			Name = "Value",
			Description = "set/schedule: the new value as JSON (true, 12, \"text\", {\"Title\":\"Hi\"}); plain text is taken as a string.",
			Optional = true
		},
		{
			Type = "duration",
			Name = "In",
			Description = "schedule only: how long from now the value takes effect, e.g. 45m or 1h30m.",
			Optional = true
		}
	}
}